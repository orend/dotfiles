---
name: html-artifacts
description: >
  Use when producing an artifact that benefits from spatial layout, side-by-side comparison,
  interactivity, or visual structure -- exploratory plans, implementation plans, code review
  writeups, PR explainers, module maps, design mockups, animation prototypes, SVG diagrams,
  slide decks, status reports, post-mortems, research explainers, or throwaway editing
  interfaces. Reach for this whenever the output shape is your call and markdown would flatten
  it, even if the user never says "HTML" -- if they ask you to compare options, explain how
  something works, write up a PR, brainstorm directions, or build a quick editor, this applies.
---

# HTML Artifacts

## Overview

Markdown is great for prose. It flattens everything else.

When the natural shape of an output is **spatial** (side-by-side, before/after, call graphs),
**visual** (mockups, palettes, diagrams), or **interactive** (animation tuning, clickable flows,
throwaway editors), produce a single self-contained `.html` file the user can open directly.

**Self-contained means fully offline.** Once saved, the file must render identically three months
from now, on a plane, with no wifi. No CDN fetches at view time, no remote fonts, no
`<img src="https://...">`. Everything inline. This isn't purism — these artifacts get uploaded,
linked in Slack, and opened on phones by people who won't debug a blank page.

Source: <https://thariqs.github.io/html-effectiveness/> · provenance and licensing in `PROVENANCE.md`.

## Start with the brief

The single biggest determinant of whether an artifact lands is knowing what it's *for* before
you open a template. Spend a moment on five things:

- **Reader** — the user alone, their team, or their leadership? Density and tone follow from this.
- **Decision or action** it enables. An artifact that informs no decision is decoration.
- **Source material** — the files, PRs, tickets, or logs you'll ground it in. Real data or none.
- **Shape** — comparison, timeline, map, explainer, editor. This picks the template.
- **Return path** — how the useful output gets back out: a decision, an export, a next prompt.

When the request is vaguer than that, the gap *is* the finding. Reach for an `unknowns/` template
and surface the ambiguity rather than papering over it with a polished page that answers the wrong
question.

## Workflow

**Don't write HTML from scratch. Start from a template.**

1. Pick a template — see "Choosing a template" below, full index in `references/template-catalog.md`.
2. Read the chosen file end-to-end. It shows the whole pattern: HTML, CSS, and JS, all inline.
3. Copy it to `/tmp/<descriptive-name>.html` or `~/Downloads/`, then edit **in place**. Copy first,
   never retype a template from scratch — you'll lose refinements you didn't notice were load-bearing.
4. Replace the demo content with the user's real content. Keep the structure, CSS, and JS.
5. Set the footer byline to `Created YYYY-MM-DD by <author>`, pulling `<author>` from
   `git config user.name`. Months later someone opens this and needs to know whose claim it is.
   Don't substitute a model name and don't skip it.
6. If it produces decisions, risks, tasks, prompts, tickets, or structured data, add a copy/export
   affordance. The user did work in your UI; let them carry it out as markdown, JSON, or a next prompt.
7. Validate when practical: `python3 scripts/blnkoff-check_html_artifact.py <file>`, and for
   SVG-heavy pages `node scripts/shivam2014-validate-html.mjs <file>`.
8. Print the absolute path so the user can `open <path>`.

If the artifact is a working interface over a durable docs surface, sync the accepted conclusions
back into the source markdown or doc once the user signs off. The HTML is the workbench, not
always the record.

## Choosing a template

Four lanes, in priority order. `references/template-catalog.md` has every entry with its situation.

| Lane | Use it when | Where |
|---|---|---|
| **Official** (20) | Default. One refined design system. | `templates/` |
| **Unknowns** (11) | Work is ambiguous or underspecified; you need a thinking surface, not a polished one. | `templates/unknowns/` |
| **Blocks** | Doc- or report-shaped, but no full template fits. Start from `thariqs-pr6-base-shell.html` and compose. | `templates/blocks/` |
| **Community** (15) | Opt-in only — **ask first** unless the user requested this lane or named a file. Mixed quality; validate harder. | `templates/community/` |

When two templates both look plausible, **pick the one whose structure matches, not the one whose
subject matter matches.** A retry-policy comparison and a colour-palette comparison are the same
artifact; a status report about that same retry policy is a different one. Structure is what a
template gives you — the subject you supply yourself.

Use HTML when it earns its keep: roughly, when two or more of *spatial layout, visual density,
comparison, interaction, durable share surface* apply — or whenever the user asks for it outright.

## Matching the host project's style

When the artifact is *about* a specific app or codebase, borrow that project's design system rather
than defaulting to ivory/slate/clay. An artifact that looks like it belongs to the consuming team
lands better than another generic ivory page.

1. Find the tokens: `tailwind.config.{js,ts}`, `theme.{css,ts}`, `tokens.json`, `src/styles/`, the
   entry stylesheet's custom properties.
2. Map **primary / accent / neutral / surface**, the **font stack**, and the **radius scale** onto
   the template's `:root`. Change nothing else.
3. Keep the template's layout, components, and structural CSS. Those are the refined part.

If you'll be building several artifacts for the same project, generate one design-system artifact
first (`templates/05-design-system.html`) and reuse it as the palette reference for the rest.
Deriving tokens once beats re-deriving them per artifact and drifting.

If the repo has no discernible design system — a CLI tool, a library, loose scripts — stay on
ivory/slate/clay. Don't invent a palette to fill silence.

## What HTML costs

Worth being honest about, because it makes the judgment real rather than arbitrary:

- **It's slower.** An HTML artifact takes meaningfully longer to generate than the equivalent
  markdown. Worth it when someone will actually read the result; wasteful for a three-line answer.
- **It diffs badly.** HTML diffs are noisy and hard to review, which is why anything that lives in
  git as documentation should stay markdown.
- **It's a snapshot.** Once saved it stops tracking the source it was built from. Date it, and
  cite the commit or PR it reflects.

## When NOT to use

- Linear narrative prose — a Slack message, a commit message, a paragraph in a doc.
- Anything tracked in git as documentation: README, design doc, ADR.
- Anything living in a terminal or chat that can't render HTML.
- When the user asked for markdown. If they named a format, that's the format.
- When markdown plus a Mermaid diagram or a GFM table is genuinely enough.
- When it would need a backend, multi-user state, secrets, or persistent storage.

## Linking to source: absolute URLs, not local paths

Artifacts get shared, so every reference to a file, PR, ticket, or sibling doc has to resolve on the
open web. A `./foo.md` link or a `/Users/...` path breaks the moment the file leaves your machine.

| Reference | Wrap as |
|---|---|
| Code path | `https://github.com/<org>/<repo>/blob/<branch>/<path>` |
| Sibling doc | `https://github.com/<org>/<repo>/blob/<branch>/<dir>/<file>` |
| PR / commit | `https://github.com/<org>/<repo>/pull/<n>` · `/commit/<sha>` |
| Ticket | `https://<jira-host>/browse/<KEY>-<n>` |

Resolve org, repo, and default branch once up front from `git remote -v` and
`git symbolic-ref refs/remotes/origin/HEAD` — don't guess `main` vs `master`. Add
`target="_blank" rel="noopener"`. Style links to the artifact's palette, not browser-default blue.
**Also wrap the footer source path** — "Created from `~/lib/foo/bar.md`" leaks a home directory.

## Reusable assets

- `assets/skeleton.html` — minimal scaffold on the shared palette, for when no template fits.
  The byline rule still applies.
- `assets/print.html` — `@media print` block. **Paste it into any document-shaped artifact**
  (reports, plans, PR writeups, explainers, incident timelines). None of the official templates
  carry one, and report-shaped artifacts get saved as PDF and mailed to people who never open the
  `.html` — without it they print an ivory background, dead toolbars, tables sliced across page
  breaks, and links whose destinations are invisible on paper. Skip it for editors and prototypes,
  where printing an interactive tool means nothing.
- `references/design-tokens.md` — the full palette, a canonical **dark** variant, typography roles,
  the size scale, and layout/visual rules. Read it when you need a palette a template doesn't
  already set: dark mode, a brand palette, or print. Artifacts default to light; produce dark only
  when asked, and self-declare it with `color-scheme` so a later reader knows the mode without
  parsing CSS.
- `assets/json-highlight.html` — drop-in CSS + JS that syntax-highlights JSON. **Include it in any
  artifact containing a JSON block.** JSON turns up in nearly every artifact (payloads, response
  shapes, schemas, fixtures) and uncolored punctuation is exactly the thing readers can't parse.
  It handles `<pre><code class="language-json">` and bare `<pre>` blocks that pass `JSON.parse`,
  skips widget-internal panels, and needs no dependencies. Same pattern works for other languages
  in volume — reuse the `tok-*` classes, swap the tokens.

## Quality pass

Before handing off:

- Verify every claim, date, count, and cost against the files or URLs you built from. Never invent
  a placeholder number — a wrong figure in a shared artifact outlives the conversation.
- Label every table and chart with units (`tokens`, `$ / 1M tokens`, `ms`, `%`).
- Check text fit at 360px and at desktop width — dense tables, cards, labels, buttons.
- Interactive controls: real `<button>`s, visible or accessible labels, sane focus order, and never
  color as the only state cue. 16px+ inputs so Mobile Safari doesn't zoom.
- SVG text: `<foreignObject>` for variable labels, backing rects behind edge labels, adequate node
  gaps, a `viewBox` sized from actual bounds.
- No secrets, no machine-local paths.
- Treat generated HTML as executable code: no unsanitized `innerHTML` for user data, no hidden
  network calls, no auto-submit side effects. Exports should be data, not instructions — shape them
  like `{ skill, kind, data, version }`. See `scripts/f-labs-submit-handler.js` for a clipboard
  fallback and export envelope worth copying.

## Common mistakes

- **Writing from scratch when a template fits.** Templates encode refinements you'd have to
  rediscover.
- **External CDNs or remote images.** Breaks offline, which is the whole promise. Inline `<svg>` for
  diagrams and icons, `data:` URIs for raster. If an asset is too big to inline (>200KB), question
  whether it belongs in the artifact.
- **Frameworks.** Plain HTML/CSS/JS. React for a one-pager is overkill.
- **Splitting one artifact across files.** One artifact is one file, everything inline — no sidecar
  `.css` or `.js`. Note this is about a single artifact: a *project* accumulating several linked
  artifacts (explorations, then mockups, then a plan) is good, and those files become durable
  context you can hand to a later session or a verification agent.
- **No date or byline.** A dateless, ownerless artifact looks orphaned the moment it's shared.
- **Format-mismatching the request.** If they asked for a Slack message or markdown, give them that.
  This skill is for when the format is your call.
- **Treating HTML as the deliverable instead of the medium.** The job is to communicate the
  comparison, the diff, the timeline. Don't over-style at the expense of clarity.

## Maintaining this library

When changing the bundled source, run `python3 scripts/validate_html_artifacts_skill.py` from
this directory. It validates every cataloged, publishable template as a self-contained artifact;
the `blocks/` snippets and the explicitly reference-only React/Babel example are deliberately
excluded because they are not standalone deliverables.

## Companion

- `gif-creator` — when an artifact needs an animated walkthrough or GIF capture.
- Live demos of every official template: <https://thariqs.github.io/html-effectiveness/>
