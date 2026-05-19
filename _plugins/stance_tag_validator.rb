require "set"
require "date"

module StanceResponseValidator
  FILTERS_KEY = "stance_filters".freeze
  RESPONSES_KEY = "stance_responses".freeze

  REQUIRED_FIELDS = %w[candidate state race party tag response date].freeze

  def self.validate(site)
    filters = site.data[FILTERS_KEY]
    return unless filters

    valid_tags = Array(filters["tags"])
    valid_races = Array(filters["races"]).to_set
    valid_parties = Array(filters["parties"]).to_set
    district_min = filters["district_min"]
    district_max = filters["district_max"]
    tag_set = valid_tags.to_set
    tag_lower = valid_tags.each_with_object({}) { |t, h| h[t.downcase] = t }

    responses = site.data[RESPONSES_KEY]
    return unless responses

    problems = []

    responses.each do |state_slug, entries|
      Array(entries).each_with_index do |entry, idx|
        label = "#{state_slug}.yml[#{idx}] — #{entry.is_a?(Hash) ? (entry["candidate"] || "(unknown candidate)") : "(non-hash entry)"}"

        unless entry.is_a?(Hash)
          problems << "  - #{label}: entry is not a mapping"
          next
        end

        REQUIRED_FIELDS.each do |f|
          if entry[f].nil? || (entry[f].is_a?(String) && entry[f].strip.empty?)
            problems << %(  - #{label}: missing required field "#{f}")
          end
        end

        if entry["state"] && entry["state"].to_s != state_slug.to_s
          problems << %(  - #{label}: state "#{entry["state"]}" does not match file slug "#{state_slug}")
        end

        if entry["race"] && !valid_races.include?(entry["race"])
          problems << %(  - #{label}: race "#{entry["race"]}" is not in stance_filters.yml races)
        end

        if entry["party"] && !valid_parties.include?(entry["party"])
          problems << %(  - #{label}: party "#{entry["party"]}" is not in stance_filters.yml parties)
        end

        district = entry["district"]
        unless district.nil?
          if !district.is_a?(Integer)
            problems << %(  - #{label}: district "#{district}" is not an integer)
          elsif district_min && district_max && (district < district_min || district > district_max)
            problems << %(  - #{label}: district #{district} is outside range #{district_min}..#{district_max})
          end
        end

        date = entry["date"]
        unless date.nil?
          ok = date.is_a?(Date) || (date.is_a?(String) && (Date.parse(date) rescue nil))
          problems << %(  - #{label}: date "#{date}" is not a valid ISO date) unless ok
        end

        tags = entry["tag"]
        unless tags.nil?
          tag_list = tags.is_a?(Array) ? tags : [tags]
          tag_list.each do |tag|
            next if tag_set.include?(tag)
            hint = tag_lower[tag.to_s.downcase]
            suffix = hint ? %( (did you mean "#{hint}"?)) : ""
            problems << %(  - #{label}: tag "#{tag}" is not in stance_filters.yml tags#{suffix})
          end
        end
      end
    end

    return if problems.empty?

    message = ["Stance response validation failed:", *problems,
               "Valid values are defined in _data/stance_filters.yml."].join("\n")
    raise message
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  StanceResponseValidator.validate(site)
end
