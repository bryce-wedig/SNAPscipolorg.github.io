# Liquid filters shared across the Stance on Science templates.
module Jekyll
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

Liquid::Template.register_filter(Jekyll::StanceDistrictFilter)
Liquid::Template.register_filter(Jekyll::StanceLiquifyFilter)
