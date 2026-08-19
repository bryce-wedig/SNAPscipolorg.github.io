# Generates one page per Stance on Science candidate, listing every response that
# candidate gave. Clicking a candidate's name in any of the three state-page views
# (group by candidate / group by topic / compare) or on the global search page
# lands here.
#
# There is no per-candidate source file and there never should be: a candidate is
# an emergent grouping of rows in _data/stance_responses/<state>.yml, so the ~200
# pages are derived at build time instead of being maintained by hand.
#
# This plugin only handles identity and routing. All markup lives in
# _includes/stance/candidate_page.html, which re-reads the response data from
# `page.state` + `page.candidate_first_name` / `page.candidate_last_name`.
require_relative "stance_liquid_filters"

module StanceCandidatePages
  # Pages are stored under site.pages, NOT the `initiatives` collection. Several
  # templates locate a state page with `site.initiatives | where: "state", <code>`
  # (responses.json, response_card.html, the map page, filter_bar.html); a
  # candidate page carrying a `state` key in that collection could win those
  # lookups. Nothing in the site iterates site.pages, so this is inert.
  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      responses = site.data["stance_responses"] || {}

      responses.each do |state, rows|
        next if state == "_blank"

        Array(rows).group_by { |row| StanceCandidate.full_name(row) }.each do |name, items|
          next if name.empty?

          site.pages << build_page(site, state, name, items.first)
        end
      end
    end

    private

    def build_page(site, state, name, first_row)
      slug = StanceCandidate.slug(name)
      dir  = "initiatives/stance-on-science/candidates/#{state}"
      page = Jekyll::PageWithoutAFile.new(site, site.source, dir, "#{slug}.html")

      # PageWithoutAFile#read_yaml sets @data but never @content, and
      # Convertible#render_with_liquid? is has_liquid_construct?(content) — which
      # is false for empty content. An unset body would therefore skip Liquid
      # entirely and render a blank page with no error, so assign it here.
      page.content = "{% include stance/candidate_page.html %}"

      # merge!, not `data =`: Page#initialize installs a default_proc on data that
      # resolves front matter defaults, and reassigning the hash would drop it.
      #
      # `state` is set (the include needs it) but `state_name` deliberately is not:
      # _includes/head.html titles a page "<state_name> Stance on Science" when both
      # are present, which would clobber every candidate's <title>.
      page.data.merge!(
        "layout"               => "gridlay",
        # Explicit permalink: the site sets no permalink style, so the default
        # (:date) would append .html and diverge from the state pages' URLs.
        "permalink"            => StanceCandidate.url(state, name),
        "title"                => name,
        "state"                => state,
        "candidate_slug"       => slug,
        "candidate_first_name" => first_row["candidate_first_name"],
        "candidate_last_name"  => first_row["candidate_last_name"]
      )

      page
    end
  end
end
