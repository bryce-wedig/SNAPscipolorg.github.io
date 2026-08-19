# Liquid filters shared across the Stance on Science templates.

# Candidate identity for Stance on Science.
#
# A candidate is not an entity anywhere in _data — it is an emergent grouping of
# response rows sharing a state and a name. This module is the single definition
# of that identity (and of the URL derived from it), shared by the page generator
# (stance_candidate_pages.rb), the validator, and the Liquid filter below that
# templates use to build hrefs.
#
# Slugs come from Jekyll::Utils.slugify, which Liquid also exposes as
# `| slugify: "latin"` — the same Ruby method, so the two sides cannot drift.
# "latin" mode transliterates accented characters (Andrés -> andres). Honorifics
# and suffixes ("M.D.", "IV") are deliberately kept: they disambiguate.
module StanceCandidate
  URL_PREFIX = "/initiatives/stance-on-science/candidates".freeze

  # A response row's candidate as a display string, e.g. "Jane Q. Doe".
  def self.full_name(row)
    [row["candidate_first_name"], row["candidate_last_name"]].compact.join(" ").strip
  end

  def self.slug(full_name)
    Jekyll::Utils.slugify(full_name.to_s.strip, :mode => "latin")
  end

  # Site-root path (no baseurl); callers pipe through relative_url.
  def self.url(state, full_name)
    "#{URL_PREFIX}/#{state}/#{slug(full_name)}"
  end
end

module Jekyll
  module StanceCandidateFilter
    # {{ full_name | stance_candidate_url: state | relative_url }}
    def stance_candidate_url(full_name, state)
      ::StanceCandidate.url(state, full_name)
    end
  end

  module StanceDistrictFilter
    # Coerce a list of district values to strings, de-duplicate, and sort in
    # natural order: numeric districts ascending (2 before 10), a lettered
    # variant right after its number ("14" before "14A"), and any non-numeric
    # values first (to_i == 0) then alphabetically.
    def sort_districts(input)
      Array(input).reject { |d| d.nil? || d.to_s.strip.empty? }
                  .map(&:to_s)
                  .uniq
                  .sort_by { |d| [d.to_i, d] }
    end
  end

  module StanceLiquifyFilter
    # Render a string that came from a data file as a Liquid template.
    #
    # Jekyll does not process Liquid in _data/**, so a response body written as
    # [letter]({{ '/files/x.pdf' | relative_url }}) would reach markdownify as
    # literal text and the link would not render. Piping through liquify first
    # lets response text use site-aware filters like relative_url, which matters
    # because the site is built with a baseurl on fork/preview deploys.
    def liquify(input)
      return input if input.nil?

      Liquid::Template.parse(input.to_s).render!(@context)
    rescue Liquid::Error => e
      raise Liquid::Error, "liquify failed to render data-file text (#{e.message}): #{input.to_s.strip[0, 120]}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::StanceCandidateFilter)
Liquid::Template.register_filter(Jekyll::StanceDistrictFilter)
Liquid::Template.register_filter(Jekyll::StanceLiquifyFilter)
