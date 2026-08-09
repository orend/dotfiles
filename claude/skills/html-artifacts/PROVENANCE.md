# Provenance

Where every bundled file came from, and when it was last checked against its source.
This file exists because the previous provenance mechanism — a star count baked into each
filename — records a claim it cannot substantiate: no repo URL, no fetch date, and no way
to re-verify. Numbers in filenames are kept only so existing references keep resolving.
**Treat them as historical, not current.**

Last refetch: **2026-08-09**.

## Primary source

- Repo: <https://github.com/ThariqS/html-effectiveness> (site: <https://thariqs.github.io/html-effectiveness/>)
- Author: Thariq Shihipar · License: Apache-2.0 (`LICENSE`, vendored here, byte-identical to upstream)
- Upstream `main` at refetch: `1787245` — "Merge branch 'add-project-docs'", 2026-07-03
- Upstream status, quoted from its README: **"Sample code. Not maintained and not accepting contributions."**

That status matters: open pull requests against this repo will not merge. Anything useful in
them has to be vendored here or it stays unavailable.

### Verified at refetch

| What | Count | Result |
|---|---|---|
| `templates/01..20-*.html` vs upstream `main` | 20 | byte-identical |
| `templates/unknowns/*.html` (incl. `index.html`) vs upstream `unknowns/` | 12 | byte-identical |
| `templates/blocks/thariqs-pr6-*` vs PR #6 head `13a2216` | 14 | byte-identical |
| `LICENSE` vs upstream | 1 | byte-identical |

The `Copyright 2026 Anthropic PBC · SPDX-License-Identifier: Apache-2.0` header on the demo
files is **upstream's own** (present on 33 upstream files), not something added here. The
placeholder brand is `Acme`; upstream de-branded from "Birchline" in its 2026-05-13 copy update.

### Local library validation

After a refresh, run:

```bash
python3 scripts/validate_html_artifacts_skill.py
```

It checks the catalog's publishable templates with the bundled offline checker, verifies the
official/unknowns inventory, and confirms every catalog path exists. The PR #6 `blocks/` files
are intentionally fragments rather than standalone pages; the React/Babel community host is
explicitly reference-only and is therefore not a candidate for an offline artifact.

### Upstream pull requests

| PR | Author | State | Disposition |
|---|---|---|---|
| #6 | `LiveLikeCounter` | open, will not merge | **Vendored** as `templates/blocks/thariqs-pr6-*` (14 files). Filename prefix names the *PR*, not the author — the author is LiveLikeCounter, not ThariqS. |
| #3 | `frntn` | open, will not merge | Mirrors the source author's own essay. **Not vendored as a file**; its substance is folded into `SKILL.md` (the artifact brief, the honest cost tradeoff, design-system-file reuse) and its example prompts into `references/template-catalog.md`. |
| #1 | `rjayasin` | open, will not merge | Ignored — a one-character footer-link fix to the gallery page, which is not vendored here. |

## Community lane

`templates/community/*` came from unrelated community skill repos, not from upstream. The
`<handle>-<N>stars-` prefix records a star count at an *unrecorded* earlier fetch date. Spot
checks on 2026-07-28 show the numbers have drifted and that several handles no longer resolve
unambiguously to a single source repo:

| Handle in filename | Best-known source | Label | Checked 2026-07-28 |
|---|---|---|---|
| `dogum` | <https://github.com/dogum/html-artifacts> | 121 | 130 — confirmed drift |
| `rob163` | <https://github.com/rob163/html-as-cli-panel-skill> | 1 | 1 — unchanged |
| `blnkoff` | <https://github.com/blnkoff/html-effectiveness> | (scripts only) | 1 |
| `jiji262` | unresolved | 139 | ambiguous — do not trust |
| `julianoczkowski` | unresolved | 6 | ambiguous — do not trust |
| `okminlee` | unresolved | 4 | ambiguous — do not trust |
| `zakelfassi` | unresolved | 13 | ambiguous — do not trust |
| `f-labs` | unresolved | 34 | ambiguous — do not trust |

Unresolved means the handle's public repos no longer contain an obvious single match, so the
labelled count could not be re-confirmed. This does not make the templates worse — they are
vendored files and render offline regardless — but it is why the community lane is ask-first
and why star counts must not be read as a quality signal.

## Scripts

| File | Origin |
|---|---|
| `scripts/blnkoff-check_html_artifact.py` | `blnkoff` — HTML artifact structural check |
| `scripts/blnkoff-new_html_artifact.py` | `blnkoff` — scaffold a new artifact |
| `scripts/blnkoff-quality-checklist.md` | `blnkoff` — review checklist |
| `scripts/shivam2014-validate-html.mjs` | `shivam2014` — HTML/SVG validation |
| `scripts/f-labs-submit-handler.js` | `f-labs` — clipboard fallback + JSON export envelope |
| `scripts/f-labs-web-probe.py` | `f-labs` — page probe |

## Re-verifying this

```bash
git clone --depth 50 https://github.com/ThariqS/html-effectiveness /tmp/ha-up
cd /tmp/ha-up && git fetch origin pull/6/head:pr6
S=~/bin/dotfiles/claude/skills/html-artifacts
for f in /tmp/ha-up/[0-9][0-9]-*.html; do cmp -s "$f" "$S/templates/$(basename $f)" || echo "DIFFERS: $f"; done
for f in /tmp/ha-up/unknowns/*.html; do cmp -s "$f" "$S/templates/unknowns/$(basename $f)" || echo "DIFFERS: $f"; done
cmp -s /tmp/ha-up/LICENSE "$S/LICENSE" || echo "DIFFERS: LICENSE"
```

Silence means current. Update the "Last refetch" date above when you run it.
