# homeBrewScripts — Session log

Dated entries of decisions, experiments, and gotchas. Newest first. Read this at session start when resuming work.

## 2026-04-29 — Site consolidated from `gh-pages` into `main /docs`

Brought `brewscripts.codecraftedapps.com` into this repo's working tree to match the pattern used by strideTrack and dailyStrideTracker. Was previously deployed from a `gh-pages` branch that didn't exist locally on `main` — easy to mistake for a separate repo.

What changed:

- Copied gh-pages contents into `docs/` on main (27 files, including favicon, apple-touch-icon, BrewBackgroundSite.png, all html, css, sitemap, robots).
- Flipped Pages source via `gh api -X PUT repos/DJCastle/homeBrewScripts/pages -f 'source[branch]=main' -f 'source[path]=/docs'`.
- Deleted remote `gh-pages` branch after confirming the new source served `HTTP 200` with fresh `last-modified`.

Gotchas / things to know next time:

- `DJCastle/brewscripts` repo does NOT exist. The root site's `SUBDOMAIN_CLAUDE_TEMPLATE.md` still references it — stale, can mislead. (Cleanup belongs in the codeCraftedApps root site repo, not here.)
- The site is fronted by Cloudflare (`server: cloudflare` in response headers), so the GitHub Pages `https_certificate: bad_authz` state seen on this and the other subdomains may be cosmetic for end users — Cloudflare terminates TLS. Worth verifying before chasing it.
- Pages config for the three subdomains is now identical: `main` branch, `/docs` path. Root site is `main /` because the repo is the site.

What's next (not done this session):

- Add OG/banner image to brewscripts site to match what strideTrack/dailyStrideTracker have (no `og-image.png` in `docs/` yet — gh-pages didn't have one either).
- Investigate the `bad_authz` cert state across the three subdomains if browser warnings appear.
