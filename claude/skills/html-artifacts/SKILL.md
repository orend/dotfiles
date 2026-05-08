---
name: html-artifacts
description: >
  Use when producing artifacts that benefit from spatial layout, side-by-side comparison,
  interactivity, or visual structure -- exploratory plans, code review writeups, design
  mockups, animation prototypes, SVG diagrams, slide decks, status reports, post-mortems,
  or throwaway editing interfaces. Markdown flattens what HTML can show.
---

# HTML Artifacts

## Overview

Markdown is great for prose. It flattens everything else.

When the natural shape of an output is **spatial** (side-by-side, before/after, call graphs), **visual** (mockups, palettes, diagrams), or **interactive** (animation tuning, clickable flows, throwaway editors), produce a single self-contained `.html` file the user can open directly in a browser.

Source: <https://thariqs.github.io/html-effectiveness/>

## Workflow

**Don't write HTML from scratch. Start from a template.**

1. Match the situation to a template in `templates/` (table below)
2. Read the template file end-to-end -- it shows the full pattern (HTML + CSS + JS, all inline)
3. Copy it to `/tmp/<descriptive-name>.html` (or `~/Downloads/`)
4. Replace the demo content with the user's actual content; reuse the structure, CSS, and JS
5. Print the absolute path so the user can `open <path>`

Templates were authored by hand and share a consistent design system: Anthropic's ivory/slate/clay palette, `ui-serif` headings over `system-ui` body, monospace for code. Match it for visual coherence across artifacts, or swap palettes wholesale when the context calls for it (e.g. dark mode, brand colors).

## When to Reach for HTML (and which template)

| Situation | Template |
|---|---|
| Compare 2-3 code approaches | `templates/01-exploration-code-approaches.html` |
| Compare visual designs / palettes | `templates/02-exploration-visual-designs.html` |
| Annotated PR with margin notes + severity tags | `templates/03-code-review-pr.html` |
| Module / package / call graph map | `templates/04-code-understanding.html` |
| Living design system (tokens as swatches) | `templates/05-design-system.html` |
| Component variants sheet (sizes/states/intents) | `templates/06-component-variants.html` |
| Animation / transition tuning with sliders | `templates/07-prototype-animation.html` |
| Clickable flow prototype (linked screens) | `templates/08-prototype-interaction.html` |
| Slide deck (arrow-key navigation) | `templates/09-slide-deck.html` |
| SVG figure sheet (inline, tweakable) | `templates/10-svg-illustrations.html` |
| Weekly status report (shipped/slipped + chart) | `templates/11-status-report.html` |
| Incident post-mortem timeline | `templates/12-incident-report.html` |
| Annotated flowchart (pipeline + failure paths) | `templates/13-flowchart-diagram.html` |
| How-a-feature-works explainer (TL;DR, tabs, FAQ) | `templates/14-research-feature-explainer.html` |
| Concept explainer (live widget + glossary) | `templates/15-research-concept-explainer.html` |
| Implementation plan (timeline, dataflow, risks) | `templates/16-implementation-plan.html` |
| PR writeup for reviewers (motivation, file tour) | `templates/17-pr-writeup.html` |
| Ticket triage board (drag, copy-as-markdown) | `templates/18-editor-triage-board.html` |
| Feature flag editor (toggles + dep warnings) | `templates/19-editor-feature-flags.html` |
| Prompt tuner (editable template, live re-render) | `templates/20-editor-prompt-tuner.html` |

## When NOT to Use

- Linear narrative prose (Slack message, commit, paragraph in a doc)
- Anything tracked in git as documentation (README, design doc, ADR)
- Anything that lives in a terminal/chat that can't render HTML
- When the user asked for markdown specifically

## Fallback Skeleton

If no template matches, start from this minimal scaffold (matches the templates' palette):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{Descriptive title}</title>
<style>
  :root {
    --ivory:#FAF9F5; --slate:#141413; --clay:#D97757; --oat:#E3DACC;
    --olive:#788C5D; --rust:#B04A3F;
    --gray-150:#F0EEE6; --gray-300:#D1CFC5; --gray-500:#87867F; --gray-700:#3D3D3A;
    --serif: ui-serif, Georgia, 'Times New Roman', serif;
    --sans: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    --mono: ui-monospace, 'SF Mono', Menlo, Monaco, monospace;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: var(--ivory); color: var(--gray-700);
         font: 14px/1.5 var(--sans); padding: 32px; }
  main { max-width: 1100px; margin: 0 auto; }
  h1, h2, h3 { font-family: var(--serif); color: var(--slate); line-height: 1.2; }
  .muted { color: var(--gray-500); font-size: 12px; }
</style>
</head>
<body>
<main>
  <h1>{Title}</h1>
  <p class="muted">Generated {YYYY-MM-DD}</p>
  <!-- semantic HTML: <details>, <table>, <figure>, <svg> -->
</main>
</body>
</html>
```

## Common Mistakes

- **Writing HTML from scratch when a template fits.** Templates encode patterns refined by the source author -- adapt, don't reinvent.
- **External CDNs (Tailwind, Google Fonts, JS libs).** Breaks offline. Breaks "open this 3 months from now." Inline everything.
- **Frameworks.** Plain HTML/CSS/JS. React/Vue/Svelte for a one-pager is overkill.
- **Multiple files.** Defeats the point. One file. Always.
- **No date / metadata.** Include "generated YYYY-MM-DD" in a footer so the user knows which is current.
- **Format-mismatching the request.** If the user asked for a Slack message or a markdown file, give them that. This skill is for cases where the format is *your* call.
- **Treating HTML as the deliverable instead of the medium.** The artifact's job is to communicate the underlying thing (the comparison, the diff, the timeline). Don't over-style at the expense of clarity.

## Companion skills

- `gif-creator` -- when an HTML artifact needs an animated walkthrough or GIF capture
- Source: <https://thariqs.github.io/html-effectiveness/> (live demos of each template)
