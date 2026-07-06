# Stance on Science state pages live at /initiatives/stance-on-science/states/<code>.
# Rather than maintaining that URL by hand in each page's front matter (which is
# error-prone — a copied-from-template page can keep the placeholder `.../xx`), we
# derive the permalink from the page's `state` code.
#
# Jekyll does not support custom front-matter variables as permalink placeholders,
# so we set `doc.data["permalink"]` directly in a :post_read hook (mirroring
# stance_last_updated.rb). URL generation is lazy and happens at render time, after
# this hook runs, so the override takes effect.
module StancePermalink
  STATES_PREFIX = "_initiatives/stance/states/".freeze

  def self.apply(site)
    collection = site.collections["initiatives"]
    return unless collection

    collection.docs.each do |doc|
      next unless doc.relative_path.to_s.start_with?(STATES_PREFIX)

      state = doc.data["state"]
      next if state.nil? || state.to_s.strip.empty?

      doc.data["permalink"] = "/initiatives/stance-on-science/states/#{state}"
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  StancePermalink.apply(site)
end
