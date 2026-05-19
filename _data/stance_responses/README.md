# Stance on Science candidate responses

Each entry is one response from one candidate, classified by one or more
tags. A candidate addressing multiple tags appears in multiple entries.

## Fields
- `candidate`: full name
- `state`: two-letter USPS code, lowercase ("ca"). Redundant with the file name, but kept on each row so it survives when the JSON feed is denormalized.
- `tag`: one tag (or a YAML list of tags) — each must match a value from `tags` in _data/stance_filters.yml
- `race`: must match a value from `races` in _data/stance_filters.yml
- `district`: integer (omit or leave null for statewide races)
- `party`: must match a value from `parties` in _data/stance_filters.yml
- `response`: candidate response in Markdown format
- `date`: ISO date the candidate submitted the response