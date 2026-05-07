# homeBrewScripts — Session log

Dated entries of decisions, experiments, and gotchas. Newest first. Read this at session start when resuming work.

---

## 2026-05-06 — CLAUDE.md restructure + Codex/AGENTS.md removed

`CLAUDE.md` reorganized to the `~/Developer/HANDOFF.md` skeleton (`9d61df9`). DNS truth pinned: `brewscripts.codecraftedapps.com` is Cloudflare-Proxied. `AGENTS.md` (Codex parallel) removed (`a0be231`) — Don is consolidating to Claude-only across all repos.

## 2026-04-29 — Site moved from `gh-pages` branch to `main /docs`

Now matches the sibling pattern (dailyStrideTracker, shoeMiles): Pages source = `main` branch, `/docs` path. The old `gh-pages` branch was deleted on the remote after the new source served HTTP 200.

**Gotcha:** the site is fronted by Cloudflare (`server: cloudflare` in response headers), so the GitHub Pages `https_certificate: bad_authz` state seen across the three subdomains may be cosmetic for end users — Cloudflare terminates TLS. Worth verifying before chasing it.

**Closed (2026-05-06):** OG image was already added — `docs/og-image.png` is 1200×630, git-tracked, referenced in `docs/index.html` OG + Twitter meta. The 2026-04-29 "open" thread was stale.
