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
5. **Set the footer byline** to `Generated YYYY-MM-DD by <author>` -- pull `<author>` from `git config user.name` (or the project's git user). Months from now, the artifact will be opened by someone who needs to know who wrote it and when. Don't skip this; don't substitute a model name.
6. Print the absolute path so the user can `open <path>`

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
  <p class="muted">Generated {YYYY-MM-DD} by {Author}</p>
  <!-- semantic HTML: <details>, <table>, <figure>, <svg> -->
</main>
</body>
</html>
```

`{Author}` comes from `git config user.name` -- never substitute a model name or omit it. Every artifact carries a byline so a future reader knows whose claim this is.

## JSON snippets: syntax-highlight by default

Plain `<pre><code>{...}</code></pre>` reads as a wall of monospace gray. JSON shows up in nearly every artifact (request payloads, response shapes, schema examples, test fixtures), so highlight it by default. Don't make readers parse colorless punctuation when the structure is the entire point.

The minimum viable highlighter is ~70 lines of inline CSS + JS, no dependencies. Drop this into every artifact that contains a `<pre>` JSON block:

```html
<style>
  .tok-key   { color: #9BB8D8; }   /* keys           */
  .tok-str   { color: #C9B98A; }   /* string values  */
  .tok-num   { color: #B7C39B; }   /* numbers        */
  .tok-bool  { color: #D97757; }   /* true / false   */
  .tok-null  { color: #87867F; font-style: italic; }
  .tok-punct { color: #87867F; }   /* { } [ ] , :    */
  .tok-cmt   { color: #87867F; font-style: italic; }   /* // comments  */
</style>

<script>
  /* Auto-highlight <pre><code class="language-json"> AND bare <pre> blocks
     whose body is valid JSON. Skips blocks inside .output-body or .codepre
     so widget-rendered code (already styled) isn't double-processed. */
  (function () {
    function escapeHTML(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
    function highlight(src){
      var i=0,n=src.length,out='';
      function emit(c,t){out+='<span class="'+c+'">'+escapeHTML(t)+'</span>';}
      while(i<n){
        var c=src[i];
        if(c==='/'&&src[i+1]==='/'){var j=src.indexOf('\n',i);if(j===-1)j=n;emit('tok-cmt',src.slice(i,j));i=j;continue;}
        if(c==='"'){var j=i+1;while(j<n){if(src[j]==='\\'){j+=2;continue;}if(src[j]==='"'){j++;break;}j++;}
          var k=j;while(k<n&&/\s/.test(src[k]))k++;emit(src[k]===':'?'tok-key':'tok-str',src.slice(i,j));i=j;continue;}
        if('{}[]:,'.includes(c)){emit('tok-punct',c);i++;continue;}
        if(/[\d-]/.test(c)){var m=src.slice(i).match(/^-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?/);if(m){emit('tok-num',m[0]);i+=m[0].length;continue;}}
        if(/[a-z]/.test(c)){var m=src.slice(i).match(/^(true|false|null)\b/);if(m){emit(m[0]==='null'?'tok-null':'tok-bool',m[0]);i+=m[0].length;continue;}}
        out+=escapeHTML(c);i++;
      }
      return out;
    }
    function process(){
      document.querySelectorAll('pre code.language-json').forEach(function(el){
        if(el.dataset.jsonHighlighted)return;el.dataset.jsonHighlighted='1';el.innerHTML=highlight(el.textContent);
      });
      document.querySelectorAll('pre').forEach(function(pre){
        var code=pre.querySelector('code');
        if(code&&/\blanguage-/.test(code.className))return;
        if(pre.closest('.output-body')||pre.closest('.codepre'))return;
        if(pre.dataset.jsonHighlighted)return;
        var t=pre.textContent.trim();if(!t||(t[0]!=='{'&&t[0]!=='['))return;
        try{JSON.parse(t);}catch(e){return;}
        pre.dataset.jsonHighlighted='1';
        if(code)code.innerHTML=highlight(t);else pre.innerHTML='<code>'+highlight(t)+'</code>';
      });
    }
    if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',process);
    else process();
  })();
</script>
```

Why this shape:
- **Colors match the dark slate palette** of the templates' code panels. Keys = light blue, strings = warm yellow, numbers = pale green, booleans = clay, null = italic gray.
- **Detects two patterns:** explicit `<pre><code class="language-json">` (markdown converters) and bare `<pre>` blocks whose body parses as JSON (hand-crafted artifacts). One block of code covers both.
- **Validates with `JSON.parse`** before highlighting bare `<pre>` so Python dict literals and other look-alikes don't get mangled.
- **Skips widget-internal `<pre>`** by checking `.closest('.output-body')` and `.closest('.codepre')`, so artifact-specific code panels (which already have their own coloring) aren't double-processed.

Apply the same pattern for other languages worth highlighting (Python, SQL, YAML) when those show up in volume — same `tok-*` class names, swap the regex tokens.

## Linking to source: use GitHub URLs, not local paths

Artifacts are shareable -- they get opened on phones, copy-pasted into Slack, sent to teammates. **Every reference to a file, PR, ticket, or sibling document must resolve as an absolute URL on the open web**, not a local-disk path or a relative `./` link that only works inside the source dir.

| Reference type | Wrap as | Example |
|---|---|---|
| Code path (`agent/foo.py`) | `https://github.com/<org>/<repo>/blob/<branch>/<path>` | `https://github.com/modmed/ai-document-agent/blob/main/agent/previsit_agent_runner.py` |
| Sibling `.md` in same dir | `https://github.com/<org>/<repo>/blob/<branch>/<dir>/<file>` | `https://github.com/modmed/ai-scribe-docs/blob/main/previsit/execution-plan.md` |
| PR (`#189` / `PR #189`) | `https://github.com/<org>/<repo>/pull/<num>` |   |
| Commit SHA | `https://github.com/<org>/<repo>/commit/<sha>` |   |
| Jira ticket (e.g. `AIMM-8006`) | `https://<jira-host>/browse/AIMM-8006` |   |

Resolve the repo / branch / Jira host once, up-front, by inspecting `git remote -v` and `git symbolic-ref refs/remotes/origin/HEAD` for the relevant repo. Don't guess `main` vs `master`.

Use `<a class="gh">` (or whatever class the template defines for inline links) and add `target="_blank" rel="noopener"`. Style: subtle dotted border-bottom that turns clay on hover -- don't use the default blue-underline browser link style; it clashes with the artifact palette.

**Also wrap the footer source path.** "Generated from `~/lib/foo/bar.md`" leaks the author's home directory. Replace with the same GitHub URL pattern.

## Common Mistakes

- **Writing HTML from scratch when a template fits.** Templates encode patterns refined by the source author -- adapt, don't reinvent.
- **External CDNs (Tailwind, Google Fonts, JS libs).** Breaks offline. Breaks "open this 3 months from now." Inline everything.
- **Frameworks.** Plain HTML/CSS/JS. React/Vue/Svelte for a one-pager is overkill.
- **Multiple files.** Defeats the point. One file. Always.
- **No date / metadata / byline.** Every artifact must end with `Generated YYYY-MM-DD by <author>` in a footer. Pull `<author>` from `git config user.name`. A dateless, ownerless artifact looks orphaned the moment it's shared.
- **Format-mismatching the request.** If the user asked for a Slack message or a markdown file, give them that. This skill is for cases where the format is *your* call.
- **Treating HTML as the deliverable instead of the medium.** The artifact's job is to communicate the underlying thing (the comparison, the diff, the timeline). Don't over-style at the expense of clarity.
- **Local-disk paths or unanchored `./foo.md` links.** See the "Linking to source" section above. Every external reference must be an absolute GitHub URL (or Jira / docs-site URL where appropriate). Local paths break the moment the artifact is opened on a different machine, shared in Slack, or downloaded by a reviewer.

## Companion skills

- `gif-creator` -- when an HTML artifact needs an animated walkthrough or GIF capture
- Source: <https://thariqs.github.io/html-effectiveness/> (live demos of each template)
