require "set"
require "date"
require_relative "stance_liquid_filters"

module StanceResponseValidator
  FILTERS_KEY = "stance_filters".freeze
  RESPONSES_KEY = "stance_responses".freeze
  QUESTIONS_KEY = "stance_questions".freeze

  RESPONSE_REQUIRED_FIELDS = %w[candidate_first_name candidate_last_name state race party question response].freeze
  QUESTION_REQUIRED_FIELDS = %w[id question tag].freeze
  COUNTY_RACE_RACE = "Local County Races [All]".freeze

  # Fields that describe the candidate rather than the individual answer. The
  # group-by-candidate cards and the generated per-candidate pages both render
  # these from whichever row happens to come first, so a candidate whose rows
  # disagree renders differently depending on YAML order — and splits into two
  # cards in the state explorer, which groups on exactly these values.
  CANDIDATE_CONSISTENT_FIELDS = %w[race district party county_race].freeze

  # A single validation failure. `row` is the 0-based position in the YAML list
  # (nil for whole-file problems), `subject` is the human name the row belongs to
  # (a candidate, a question id), `kind` is the short bucket the report groups
  # by, and `detail` is the offending value.
  Problem = Struct.new(:file, :row, :subject, :kind, :detail, keyword_init: true)

  # Printed once per `kind` group instead of repeating on every row.
  HINTS = {
    "invalid date" => "dates must be ISO 8601, e.g. 2026-07-13",
    "unknown race" => "allowed values: _data/stance_filters.yml → races",
    "unknown party" => "allowed values: _data/stance_filters.yml → parties",
    "unknown tag" => "allowed values: _data/stance_filters.yml → tags",
    "blank district" => "omit `district` entirely for statewide races",
    "state does not match file" => "the `state` field must equal the file's slug",
    "invalid primary_candidate" => "must be literally true or false",
    "inconsistent primary_candidate" => "it describes the candidate, so every row for them must agree",
    "inconsistent candidate details" => "these describe the candidate, so every row for them must agree",
    "duplicate response" => "one row per candidate per question",
    "duplicate candidate slug" => "each candidate's page URL is derived from their name; two candidates in one state cannot share one",
    "no state page for response file" => "responses are only reachable through their state page, and candidate pages link back to it",
    "missing county_race" => %(required whenever race is "#{COUNTY_RACE_RACE}"),
    "unexpected county_race" => %(only allowed when race is "#{COUNTY_RACE_RACE}"),
    "invalid races list" => "omit `races` when the question applies to every race",
  }.freeze

  # Beyond this a group is summarised; the pattern is already obvious by then.
  MAX_ENTRIES_PER_KIND = 20
  RULE_WIDTH = 72

  def self.validate_filters(site)
    filters = site.data[FILTERS_KEY]
    return unless filters

    races = Array(filters["races"])
    ballot_order = Array(filters["race_ballot_order"])
    file = "_data/stance_filters.yml"

    problems = []
    (races - ballot_order).each do |race|
      problems << Problem.new(:file => file, :kind => "missing from race_ballot_order", :detail => %("#{race}"))
    end
    (ballot_order - races).each do |race|
      problems << Problem.new(:file => file, :kind => "missing from races", :detail => %("#{race}"))
    end

    report_and_raise("Stance filter validation failed", problems,
                     "`races` and `race_ballot_order` must contain exactly the same entries.")
  end

  def self.validate(site)
    filters = site.data[FILTERS_KEY]
    return unless filters

    valid_tags = Array(filters["tags"])
    valid_races = Array(filters["races"]).to_set
    valid_parties = Array(filters["parties"]).to_set
    tag_set = valid_tags.to_set
    tag_lower = valid_tags.each_with_object({}) { |t, h| h[t.downcase] = t }

    problems = []

    question_ids_by_state = {}
    questions = site.data[QUESTIONS_KEY]
    if questions
      questions.each do |state_slug, entries|
        next if state_slug == "_blank"
        file = "_data/stance_questions/#{state_slug}.yml"
        seen_ids = {}
        Array(entries).each_with_index do |entry, idx|
          add = lambda do |kind, detail = nil|
            problems << Problem.new(:file => file, :row => idx, :kind => kind, :detail => detail,
                                    :subject => (entry["id"] if entry.is_a?(Hash)))
          end

          unless entry.is_a?(Hash)
            add.call("entry is not a mapping")
            next
          end

          QUESTION_REQUIRED_FIELDS.each do |f|
            if entry[f].nil? || (entry[f].is_a?(String) && entry[f].strip.empty?)
              add.call("missing required field", %("#{f}"))
            end
          end

          id = entry["id"]
          if id && !id.to_s.strip.empty?
            if seen_ids.key?(id)
              add.call("duplicate question id", %("#{id}" — also at entry #{seen_ids[id]}))
            else
              seen_ids[id] = idx
            end
          end

          validate_tags(entry["tag"], tag_set, tag_lower, add)

          # Race-specific questions are displayed on state pages, so validate
          # their applicability against the same canonical race list used by
          # candidate responses and explorer filters.
          question_races = entry["races"]
          unless question_races.nil?
            if !question_races.is_a?(Array)
              add.call("invalid races list", "must be a YAML list")
            elsif question_races.empty?
              add.call("invalid races list", "is empty")
            else
              question_races.each do |race|
                add.call("unknown race", %("#{race}")) unless valid_races.include?(race)
              end
            end
          end
        end
        question_ids_by_state[state_slug] = seen_ids.keys.to_set
      end
    end

    responses = site.data[RESPONSES_KEY]
    if responses
      responses.each do |state_slug, entries|
        next if state_slug == "_blank"
        file = "_data/stance_responses/#{state_slug}.yml"
        valid_question_ids = question_ids_by_state[state_slug] || Set.new
        primary_by_candidate = {}
        details_by_candidate = {}
        questions_by_candidate = {}
        names_by_slug = {}
        Array(entries).each_with_index do |entry, idx|
          name = candidate_name(entry)
          add = lambda do |kind, detail = nil|
            problems << Problem.new(:file => file, :row => idx, :kind => kind, :detail => detail,
                                    :subject => (name.empty? ? "(unnamed candidate)" : name))
          end

          unless entry.is_a?(Hash)
            add.call("entry is not a mapping")
            next
          end

          RESPONSE_REQUIRED_FIELDS.each do |f|
            if entry[f].nil? || (entry[f].is_a?(String) && entry[f].strip.empty?)
              add.call("missing required field", %("#{f}"))
            end
          end

          if entry["state"] && entry["state"].to_s != state_slug.to_s
            add.call("state does not match file", %("#{entry["state"]}" — expected "#{state_slug}"))
          end

          if entry["race"] && !valid_races.include?(entry["race"])
            add.call("unknown race", %("#{entry["race"]}"))
          end

          if entry["party"] && !valid_parties.include?(entry["party"])
            add.call("unknown party", %("#{entry["party"]}"))
          end

          district = entry["district"]
          if !district.nil? && district.to_s.strip.empty?
            add.call("blank district")
          end

          date = entry["date"]
          unless date.nil?
            ok = date.is_a?(Date) || (date.is_a?(String) && (Date.parse(date) rescue nil))
            add.call("invalid date", %("#{date}")) unless ok
          end

          question_ref = entry["question"]
          if question_ref && !question_ref.to_s.strip.empty? && !valid_question_ids.include?(question_ref)
            add.call("unknown question id", %("#{question_ref}" — no match in _data/stance_questions/#{state_slug}.yml))
          end

          # A candidate answers each question once. A repeat is a copy-paste slip
          # that would otherwise render as the same answer twice on their page.
          if !name.empty? && question_ref && !question_ref.to_s.strip.empty?
            seen_questions = (questions_by_candidate[name] ||= {})
            if seen_questions.key?(question_ref)
              add.call("duplicate response", %("#{question_ref}" — also at entry #{seen_questions[question_ref]}))
            else
              seen_questions[question_ref] = idx
            end
          end

          race_val = entry["race"]
          county_race_val = entry["county_race"]
          county_race_blank = county_race_val.nil? || (county_race_val.is_a?(String) && county_race_val.strip.empty?)
          if race_val == COUNTY_RACE_RACE && county_race_blank
            add.call("missing county_race")
          elsif !county_race_blank && race_val != COUNTY_RACE_RACE
            add.call("unexpected county_race", %("#{county_race_val}"))
          end

          primary = entry["primary_candidate"]
          unless primary.nil?
            if primary != true && primary != false
              add.call("invalid primary_candidate", %("#{primary}"))
            end
          end
          # primary_candidate is a property of the candidate, not the individual
          # response, so it must be the same on every row for a given candidate.
          # A missing field and false mean the same thing.
          unless name.empty?
            (primary_by_candidate[name] ||= Set.new) << (primary == true)

            # Districts arrive from YAML as integers, so compare as strings, and
            # treat an absent value and a blank one as the same thing.
            fields = (details_by_candidate[name] ||= {})
            CANDIDATE_CONSISTENT_FIELDS.each do |f|
              value = entry[f]
              value = nil if value.is_a?(String) && value.strip.empty?
              (fields[f] ||= Set.new) << value&.to_s
            end

            (names_by_slug[StanceCandidate.slug(name)] ||= Set.new) << name
          end
        end

        primary_by_candidate.each do |cand_name, values|
          next unless values.size > 1
          problems << Problem.new(:file => file, :subject => cand_name, :kind => "inconsistent primary_candidate")
        end

        details_by_candidate.each do |cand_name, fields|
          fields.each do |field, values|
            next unless values.size > 1
            shown = values.map { |v| v.nil? ? "(none)" : %("#{v}") }.sort.join(" vs ")
            problems << Problem.new(:file => file, :subject => cand_name,
                                    :kind => "inconsistent candidate details", :detail => "#{field}: #{shown}")
          end
        end

        # Jekyll only logs a soft "Conflict:" warning when two pages want the same
        # destination, so a collision here would silently drop one candidate's page.
        names_by_slug.each do |slug, names|
          next unless names.size > 1
          problems << Problem.new(:file => file, :subject => names.sort.join(" / "),
                                  :kind => "duplicate candidate slug", :detail => %("#{slug}"))
        end
      end
    end

    report_and_raise("Stance response validation failed", problems,
                     "Valid values are defined in _data/stance_filters.yml.")
  end

  def self.candidate_name(entry)
    return "" unless entry.is_a?(Hash)
    [entry["candidate_first_name"], entry["candidate_last_name"]].compact.join(" ").strip
  end

  # Every state page must declare the front matter its body and the shared
  # includes depend on. These are the single source of truth for the state's
  # code, display name, contact link, and voter-lookup link across the map,
  # filter bar, response cards, responses.json feed, and page header — a missing
  # value silently leaks blanks or broken links, so fail the build instead. This
  # list mirrors the "Required front matter" section documented in template.html.
  #
  # State pages are identified by their location (files under the states
  # directory) rather than by the presence of a `state` field, so that a page
  # which forgot `state` entirely is still caught instead of silently ignored.
  TEMPLATE_STATE_CODE = "xx".freeze
  STATE_PAGE_DIR = "stance/states/".freeze
  TEMPLATE_BASENAME = "template.html".freeze
  STATE_PAGE_REQUIRED_FIELDS = %w[
    state state_name demonym_plural team_email ballot_lookup_url ballot_lookup_label
  ].freeze

  def self.validate_state_pages(site)
    collection = site.collections["initiatives"]
    return unless collection

    problems = []
    page_states = Set.new
    collection.docs.each do |doc|
      path = doc.relative_path.to_s
      next unless path.include?(STATE_PAGE_DIR)
      next if File.basename(path) == TEMPLATE_BASENAME
      # The template placeholder renders at the `xx` code; skip any copy still
      # carrying it (it isn't a real, published state page).
      next if doc.data["state"].to_s == TEMPLATE_STATE_CODE

      page_states << doc.data["state"].to_s

      STATE_PAGE_REQUIRED_FIELDS.each do |f|
        value = doc.data[f]
        if value.nil? || (value.is_a?(String) && value.strip.empty?)
          problems << Problem.new(:file => path, :kind => "missing required front matter", :detail => %("#{f}"))
        end
      end
    end

    # The reverse direction: a response file with no state page would strand its
    # candidates. Their names still link to generated candidate pages, and those
    # pages link back to a state page that does not exist. (A state page with no
    # response file is fine — it just has nothing to show yet.)
    (site.data[RESPONSES_KEY] || {}).each_key do |state_slug|
      next if state_slug == "_blank"
      next if page_states.include?(state_slug.to_s)

      problems << Problem.new(:file => "_data/stance_responses/#{state_slug}.yml",
                              :kind => "no state page for response file",
                              :detail => %(no page under _initiatives/#{STATE_PAGE_DIR} declares state: "#{state_slug}"))
    end

    report_and_raise("Stance state page validation failed", problems,
                     "Every state page must define: #{STATE_PAGE_REQUIRED_FIELDS.join(", ")}.")
  end

  def self.validate_tags(tags, tag_set, tag_lower, add)
    return if tags.nil?
    tag_list = tags.is_a?(Array) ? tags : [tags]
    tag_list.each do |tag|
      next if tag_set.include?(tag)
      hint = tag_lower[tag.to_s.downcase]
      suffix = hint ? %( — did you mean "#{hint}"?) : ""
      add.call("unknown tag", %("#{tag}"#{suffix}))
    end
  end

  # Jekyll's logger squashes every run of whitespace in an exception message
  # into a single space (see Jekyll::LogAdapter#message), which turns a
  # multi-line report into one unreadable paragraph. So print the real report to
  # stderr ourselves and raise only a one-line summary that points at it.
  def self.report_and_raise(title, problems, footer)
    return if problems.empty?

    report = render(title, problems, footer)
    $stderr.puts(report)
    $stderr.flush
    write_report_file(report)

    files = problems.map(&:file).uniq.size
    raise "#{title}: #{plural(problems.size, "problem")} in #{plural(files, "file")} " \
          "(full report printed above)."
  end

  # CI opens an issue when the deploy fails. Writing the report to the path in
  # STANCE_VALIDATION_REPORT lets that workflow quote it verbatim instead of
  # scraping it back out of the job log, where it is buried between Jekyll's
  # progress output and its backtrace.
  def self.write_report_file(report)
    path = ENV["STANCE_VALIDATION_REPORT"].to_s
    return if path.empty?

    File.write(path, "#{report.gsub(%r!\e\[[0-9;]*m!, "")}\n")
  rescue SystemCallError => e
    warn "Could not write validation report to #{path}: #{e.message}"
  end

  def self.render(title, problems, footer)
    rule = "=" * RULE_WIDTH
    files = problems.group_by(&:file)

    out = ["", red(rule), red(bold(title)),
           red("#{plural(problems.size, "problem")} in #{plural(files.size, "file")}"), red(rule)]

    files.each do |file, file_problems|
      out << ""
      out << "#{bold(file)}  (#{file_problems.size})"

      file_problems.group_by(&:kind).each do |kind, kind_problems|
        out << ""
        out << "  #{yellow(kind)} (#{kind_problems.size})"
        out << dim("    #{HINTS[kind]}") if HINTS[kind]

        lines = summarize(kind_problems)
        lines.first(MAX_ENTRIES_PER_KIND).each { |line| out << "    #{line}" }
        if lines.size > MAX_ENTRIES_PER_KIND
          out << dim("    ...and #{lines.size - MAX_ENTRIES_PER_KIND} more like this")
        end
      end
    end

    out << ""
    out << footer
    out << dim("Entry numbers are 0-based positions in the YAML list.") if problems.any?(&:row)
    out << ""
    out.join("\n")
  end

  # Collapse problems that say the same thing about the same subject into one
  # line with a compacted range of entry numbers, so 40 identical typos read as
  # "entries 40-79" instead of forty near-identical lines.
  def self.summarize(problems)
    entries = problems.group_by { |p| [p.subject, p.detail] }.map do |(subject, detail), group|
      rows = group.map(&:row).compact.uniq.sort
      [rows.first || -1, row_label(rows), [subject, detail].compact.reject { |s| s.to_s.empty? }.join(": ")]
    end
    entries.sort_by! { |first_row, _, description| [first_row, description] }

    width = entries.map { |_, label, _| label.length }.max.to_i
    entries.map do |_, label, description|
      width.zero? ? description : "#{label.ljust(width)}  #{description}"
    end
  end

  def self.row_label(rows)
    return "" if rows.empty?

    ranges = rows.slice_when { |a, b| b != a + 1 }.map do |run|
      run.size == 1 ? run.first.to_s : "#{run.first}-#{run.last}"
    end
    "#{rows.size == 1 ? "entry" : "entries"} #{ranges.join(", ")}"
  end

  def self.plural(count, noun)
    "#{count} #{noun}#{"s" unless count == 1}"
  end

  def self.color?
    return @color unless @color.nil?
    @color = $stderr.tty? && ENV["NO_COLOR"].to_s.empty?
  end

  def self.paint(code, text)
    color? ? "\e[#{code}m#{text}\e[0m" : text
  end

  def self.bold(text) = paint("1", text)
  def self.dim(text) = paint("2", text)
  def self.red(text) = paint("31", text)
  def self.yellow(text) = paint("33", text)
end

Jekyll::Hooks.register :site, :post_read do |site|
  StanceResponseValidator.validate_filters(site)
  StanceResponseValidator.validate_state_pages(site)
  StanceResponseValidator.validate(site)
end
