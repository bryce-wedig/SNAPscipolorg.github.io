# Meet the Team strips

One file per state (`<state>.yml`, lowercase USPS code, e.g. `pa.yml`), exposed to
Jekyll as `site.data.stance_team.<state>` and rendered by
`_includes/stance/meet_the_team.html` at the bottom of that state's page.

If a state has no file here, its page shows no "Meet the Team" section (the include
is a no-op on empty/absent data), so adding the include everywhere is harmless.

## Format
Each file is a list. Each entry is **either** an image card **or** an Instagram
embed — not both. Order in the file is the left-to-right order in the horizontal
scroll strip.

### Image card
- `image`: filename of a JPG/PNG in `images/stance_teams/<state>/` (e.g. `victoria.jpg`).
  These are typically the finished Instagram-style "Meet the Team" card graphics.
- `alt`: descriptive alt text for accessibility. Optional but strongly encouraged.

```yaml
- image: victoria.jpg
  alt: "Meet the PA team: Victoria — MPH student, University of Pittsburgh"
```

### Instagram embed
- `instagram`: the public permalink of an Instagram post or reel
  (e.g. `https://www.instagram.com/p/ABC123xyz/`). Rendered live via Instagram's
  `embed.js`, so the account/post must be public.

```yaml
- instagram: https://www.instagram.com/p/ABC123xyz/
```
