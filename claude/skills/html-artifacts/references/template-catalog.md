# Template Catalog

Full index of every bundled template, in the order you should consider them.
Read this when picking a starting point; `SKILL.md` carries only the selection heuristic.

- [Lane 1 — Official templates](#lane-1--official-templates) (20) — the default set
- [Lane 2 — Unknowns / preflight](#lane-2--unknowns--preflight) (11) — thinking surfaces
- [Lane 3 — Blocks](#lane-3--blocks) — compose a custom doc
- [Lane 4 — Community](#lane-4--community) (15) — ask first
- [What a good artifact request looks like](#what-a-good-artifact-request-looks-like)

## Lane 1 — Official templates

Authored by hand and refined; they share one design system (ivory/slate/clay, `ui-serif`
headings over `system-ui` body, monospace for code). Start here.

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

### The lifecycle arc

Four of these are one workflow, not four unrelated pages. A piece of work often moves through
them in order, and each artifact becomes durable context for the next session or a verification
agent:

1. **Investigate** — `unknowns/01-blindspot-pass.html` or an exploration template. What don't we know?
2. **Design** — `16-implementation-plan.html`. The plan you hand off.
3. **Record during the build** — `unknowns/09-implementation-notes.html`. Deviations, tradeoffs,
   open questions, captured while they're still fresh.
4. **Explain what shipped** — `17-pr-writeup.html`. Motivation, file tour, where to focus review.

If a user asks for "notes on what I changed and why" mid-build, that's (3), not (2) — a plan
describes intent, notes record what actually happened to it.

## Lane 2 — Unknowns / preflight

Reach for these when the user needs to find what's *missing* before code or decisions
harden — not a polished explainer. These are thinking surfaces, and their value is being
cheap to change.

| Situation | Template |
|---|---|
| Blindspot scan before building | `templates/unknowns/01-blindspot-pass.html` |
| Domain explainer for a tricky concept | `templates/unknowns/02-color-grading-explainer.html` |
| Visual directions / design alternatives | `templates/unknowns/03-design-directions.html` |
| Throwaway UI mock before wiring | `templates/unknowns/04-toolbar-mock.html` |
| Intervention or churn brainstorm | `templates/unknowns/05-churn-brainstorm.html` |
| Clarifying interview / decision prompts | `templates/unknowns/06-interview.html` |
| Reference port / semantic mapping | `templates/unknowns/07-reference-port.html` |
| Tweakable implementation plan | `templates/unknowns/08-implementation-plan.html` |
| Implementation notes with caveats | `templates/unknowns/09-implementation-notes.html` |
| Ship / buy-in pitch doc | `templates/unknowns/10-pitch-doc.html` |
| Merge-readiness or comprehension quiz | `templates/unknowns/11-change-quiz.html` |

## Lane 3 — Blocks

When the artifact is doc- or report-shaped but no full template fits, compose instead of
improvising. Start from `templates/blocks/thariqs-pr6-base-shell.html`, add
`thariqs-pr6-blocks-toc.html`, then paste the fragments you need:

`callout`, `code-grid`, `collapsible`, `diagram`, `event-timeline`, `sources`,
`summary-cards`, `swatches`, `table`, `timeline`, `toc`
— each as `templates/blocks/thariqs-pr6-blocks-<name>.html`.

Provenance: upstream pull request #6 by `LiveLikeCounter`, which will not merge — the
upstream repo is explicitly "not accepting contributions." See `PROVENANCE.md`.

## Lane 4 — Community

Full templates copied from unrelated community skill repos. Filenames carry the source
handle and the star count *at fetch time*, so provenance stays visible and staleness is
obvious. This is a mixed-quality inspiration shelf, not the design system.

**Ask before building a deliverable on one of these**, unless the user requested the
community lane or named a template. Inspecting them for ideas is always fine. If the user
approves one, validate it harder than an official template: offline rendering, accessibility,
mobile fit, and hidden network or dependency assumptions.

| Situation | Template |
|---|---|
| Self-scaling slide/deck stage with print support | `templates/community/jiji262-139stars-deck-stage.html` |
| Labeled design-direction canvas | `templates/community/jiji262-139stars-design-canvas.html` |
| Live tweaks panel / adjustable design | `templates/community/jiji262-139stars-tweaks-starter.html` |
| SSE / technical comparison explainer | `templates/community/dogum-121stars-sse-comparison.html` |
| Drag/copy triage editor | `templates/community/dogum-121stars-triage-editor.html` |
| Flowchart / architecture explainer | `templates/community/dogum-121stars-flowchart.html` |
| Operator brief / executive packet | `templates/community/zakelfassi-13stars-operator-brief.html` |
| Decision brief / recommendation packet | `templates/community/zakelfassi-13stars-decision-brief.html` |
| Incident timeline | `templates/community/zakelfassi-13stars-incident-timeline.html` |
| PR review packet | `templates/community/zakelfassi-13stars-pr-review-packet.html` |
| Reusable base shell with export patterns | `templates/community/julianoczkowski-6stars-base.html` |
| Offline command panel for CLI workflows | `templates/community/rob163-1star-cli-panel-template.html` |
| SVG text-fit / diagram label safety demo | `templates/community/f-labs-34stars-svg-text-fit-demo.html` |
| Wireframe / design directions reference | `templates/community/okminlee-4stars-aurora-wireframes.html` |
| React/Babel host reference **only** — adapt to no-CDN before shipping | `templates/community/okminlee-4stars-jsx-host-reference-cdn.html` |

## What a good artifact request looks like

These are the source author's own example prompts. They're here as calibration: notice that
each one names the *shape* of the output and the *decision* it serves, not just a topic.
When a user's request is vaguer than these, that gap is what the brief in `SKILL.md` closes —
and often what an `unknowns/` template should surface rather than paper over.

- "I'm not sure what direction to take the onboarding screen. Generate 6 distinctly different
  approaches — vary layout, tone, and density — and lay them out in a grid so I can compare
  them side by side. Label each with the tradeoff it's making."
- "Help me review this PR. I'm not familiar with the streaming/backpressure logic so focus
  there. Render the actual diff with inline margin annotations, color-code findings by severity."
- "I don't understand how our rate limiter works. Produce a single explainer page: a diagram of
  the token-bucket flow, the 3-4 key code snippets annotated, and a 'gotchas' section. Optimize
  it for someone reading it once."
- "I need to reprioritize these 30 tickets. Each ticket as a draggable card across
  Now / Next / Later / Cut. Pre-sort them by your best guess. Add a 'copy as markdown' button
  that exports the final ordering with a one-line rationale per bucket."
- "I'm tuning this system prompt. Side-by-side editor: editable prompt on the left with variable
  slots highlighted, three sample inputs on the right that re-render live. Add a token counter."

Recurring pattern worth copying: **the interactive ones all end in an export.** The user does
something in the UI, then carries the result back out as markdown, JSON, or the next prompt.
