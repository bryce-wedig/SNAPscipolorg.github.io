# Candidate responses

Each entry is one response from one candidate.

Note that if any of these fields are invalid (e.g., not present in _data/stance_filters.yml), the website build will fail.

## Fields
Required:
- `candidate_first_name`: candidate's first name. This might include a title (e.g., Dr.) and a middle name, so that `candidate_first_name` + `candidate_last_name` gives the candidate's full name
- `candidate_last_name`: candidate's last name, used to sort candidates alphabetically
- `state`: two-letter USPS code, lowercase ("ca"). Redundant with the file name, but kept on each row so it survives when the JSON feed is denormalized
- `race`: must match a value from `races` in `_data/stance_filters.yml`
- `party`: must match a value from `parties` in `_data/stance_filters.yml`
- `question`: must match the `id` attribute on the corresponding question. Not required (and must be omitted) when `did_not_respond` is `true`
- `response`: candidate response in Markdown format. Not required (and must be omitted) when `did_not_respond` is `true`

Optional:
- `district`: string — a district identifier, which may include a letter (e.g. `14A`). Omit or leave null for statewide races. Plain numbers (e.g. `6`) are also accepted and treated as strings
- `date`: ISO date the candidate submitted the response
- `county_race`: free-text name of the specific county-level race (e.g., "Baca County Commissioner"). Required when `race` is "Local County Races [All]", and only allowed when `race` is "Local County Races [All]". The value itself is not validated against a picklist
- `primary_candidate`: boolean. Set `true` for a candidate who ran in the primary election but did not advance past it. Defaults to `false` when omitted (a missing field and `false` mean the same thing). These responses are hidden by default and revealed by the "Show primary candidates" toggle. Because the flag is a property of the candidate (not the individual response), it must be the same on every row for a given candidate — the build will fail if a candidate's rows disagree
- `did_not_respond`: boolean. Set `true` for a candidate who did not respond to **any** questions. Defaults to `false` when omitted (a missing field and `false` mean the same thing). These candidates are hidden by default and revealed by the "Show candidates who did not respond" toggle. Because the flag is a property of the candidate (not the individual response), it must be the same on every row for a given candidate — the build will fail if a candidate's rows disagree

## Candidates who did not respond

A non-responding candidate gets exactly **one** row — not one per question — carrying `did_not_respond: true` and no `question` and no `response`. Everything else (`candidate_first_name`, `candidate_last_name`, `state`, `race`, `party`, and any of the optional fields) is still required so that they appear on the site.
