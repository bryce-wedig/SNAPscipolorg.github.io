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
- `question`: must match the `id` attribute on the corresponding question
- `response`: candidate response in Markdown format

Optional:
- `district`: integer (omit or leave null for statewide races)
- `date`: ISO date the candidate submitted the response
- `county_race`: free-text name of the specific county-level race (e.g., "Baca County Commissioner"). Required when `race` is "Local County Races [All]", and only allowed when `race` is "Local County Races [All]". The value itself is not validated against a picklist