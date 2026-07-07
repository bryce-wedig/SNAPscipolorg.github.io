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
end

Liquid::Template.register_filter(Jekyll::StanceDistrictFilter)
