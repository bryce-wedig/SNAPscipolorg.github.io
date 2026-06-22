require "time"
require "open3"

# Stance on Science state pages display a "Last updated: …" date. Rather than
# maintaining that date by hand, we derive it from the last git commit that
# touched the page's corresponding _data/stance_responses/<state>.yml file.
#
# We use the git commit date (not the filesystem mtime) because the deploy build
# runs from a fresh `actions/checkout`, which resets every file's mtime to the
# build time. The build workflows fetch full history (fetch-depth: 0) so the
# per-file `git log` lookups below resolve.
module StanceLastUpdated
  STATES_PREFIX = "_initiatives/stance/states/".freeze
  TEMPLATE_BASENAME = "template.html".freeze

  def self.apply(site)
    collection = site.collections["initiatives"]
    return unless collection

    cache = {}

    collection.docs.each do |doc|
      next unless doc.relative_path.to_s.start_with?(STATES_PREFIX)
      next if File.basename(doc.path) == TEMPLATE_BASENAME

      state = doc.data["state"]
      next if state.nil? || state.to_s.strip.empty?

      yaml_path = File.join(site.source, "_data", "stance_responses", "#{state}.yml")
      next unless File.file?(yaml_path)

      last_updated = last_modified(site, yaml_path, cache)
      doc.data["last_updated"] = last_updated if last_updated
    end
  end

  # Returns the date of the last git commit that touched the file as a Time,
  # falling back to the filesystem mtime when the file is untracked / not yet
  # committed or git is otherwise unavailable.
  def self.last_modified(site, path, cache)
    cache.fetch(path) { cache[path] = compute_last_modified(site, path) }
  end

  def self.compute_last_modified(site, path)
    rel = path.sub(/\A#{Regexp.escape(site.source)}\/?/, "")
    iso = nil
    begin
      out, status = Open3.capture2("git", "-C", site.source, "log", "-1", "--format=%cI", "--", rel)
      iso = out.strip if status.success?
    rescue StandardError
      iso = nil
    end
    return Time.parse(iso) if iso && !iso.empty?

    # Untracked / uncommitted file or git unavailable: fall back to mtime.
    File.mtime(path) if File.file?(path)
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  StanceLastUpdated.apply(site)
end
