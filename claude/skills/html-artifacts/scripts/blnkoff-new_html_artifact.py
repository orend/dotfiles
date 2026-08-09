#!/usr/bin/env python3
"""Create a self-contained starter HTML artifact for common HTML-effectiveness patterns."""

from __future__ import annotations

import argparse
import html
from pathlib import Path

PATTERNS = {
    "exploration": {
        "eyebrow": "Exploration",
        "summary": "Compare alternatives side by side, then choose a direction.",
        "sections": ["Option A", "Option B", "Option C", "Recommendation"],
    },
    "implementation-plan": {
        "eyebrow": "Implementation plan",
        "summary": "Make the handoff independently executable.",
        "sections": ["Milestones", "Data flow", "Mockups", "Key code", "Risks", "Open questions"],
    },
    "code-review": {
        "eyebrow": "Code review",
        "summary": "Show what changed, where risk lives, and what to fix next.",
        "sections": ["What changed", "Risk map", "Annotated files", "Suggested next steps"],
    },
    "explainer": {
        "eyebrow": "Research & learning",
        "summary": "Explain the path through the system or concept once, clearly.",
        "sections": ["TL;DR", "Files or sources read", "Step-by-step path", "Gotchas", "FAQ"],
    },
    "report": {
        "eyebrow": "Report",
        "summary": "Turn recurring status or incident details into a skimmable page.",
        "sections": ["Key metrics", "Highlights", "Timeline", "Carryover", "Sources"],
    },
    "editor": {
        "eyebrow": "Custom editor",
        "summary": "Let the user manipulate data directly, then export the result.",
        "sections": ["Inputs", "Workspace", "Validation", "Pending changes", "Export"],
    },
}

CSS = """
:root { color-scheme: light dark; --bg:#faf9f5; --fg:#141413; --muted:#6f6d66; --card:#fff; --line:#e3dacc; --accent:#d97757; --ok:#788c5d; --warn:#c78e3f; }
@media (prefers-color-scheme: dark) { :root { --bg:#141413; --fg:#faf9f5; --muted:#b8b3a8; --card:#201f1d; --line:#3d3d3a; } }
* { box-sizing:border-box; }
body { margin:0; font:16px/1.55 system-ui, -apple-system, Segoe UI, sans-serif; background:var(--bg); color:var(--fg); }
main { width:min(1160px, calc(100% - 32px)); margin:32px auto 56px; }
header { display:grid; gap:8px; margin-bottom:22px; }
.eyebrow { color:var(--accent); font-weight:750; text-transform:uppercase; letter-spacing:.08em; font-size:12px; }
h1 { margin:0; font-size:clamp(32px, 5vw, 56px); line-height:1.05; letter-spacing:-.03em; }
.summary { max-width:760px; color:var(--muted); font-size:18px; }
nav { display:flex; flex-wrap:wrap; gap:8px; margin:24px 0; }
nav a { color:var(--fg); text-decoration:none; border:1px solid var(--line); border-radius:999px; padding:7px 10px; background:var(--card); }
.grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(260px, 1fr)); gap:16px; }
.card { background:var(--card); border:1px solid var(--line); border-radius:18px; padding:18px; box-shadow:0 1px 2px rgb(0 0 0 / .06); }
.card h2 { margin:0 0 8px; font-size:20px; }
.card p { color:var(--muted); }
.badge { display:inline-flex; border-radius:999px; padding:4px 8px; background:color-mix(in srgb, var(--accent), transparent 86%); color:var(--accent); font-size:12px; font-weight:700; }
pre { overflow:auto; padding:14px; border-radius:12px; border:1px solid var(--line); background:color-mix(in srgb, var(--line), transparent 55%); }
button { border:0; border-radius:999px; background:var(--accent); color:white; padding:10px 14px; font-weight:750; cursor:pointer; }
textarea { width:100%; min-height:110px; border:1px solid var(--line); border-radius:12px; padding:12px; background:var(--bg); color:var(--fg); }
""".strip()


def slugify(text: str) -> str:
    return "".join(ch.lower() if ch.isalnum() else "-" for ch in text).strip("-") or "section"


def render(pattern: str, title: str) -> str:
    spec = PATTERNS[pattern]
    safe_title = html.escape(title)
    nav = "\n".join(
        f'<a href="#{slugify(s)}">{html.escape(s)}</a>' for s in spec["sections"]
    )
    cards = []
    for section in spec["sections"]:
        body = "Replace this placeholder with artifact-specific content, evidence, visuals, controls, or code."
        if pattern == "editor" and section == "Export":
            body = '<textarea id="exportText">Replace with generated markdown, JSON, diff, or prompt.</textarea><p><button type="button" onclick="copyExport()">Copy export</button></p>'
        cards.append(
            f'<article class="card" id="{slugify(section)}"><span class="badge">todo</span><h2>{html.escape(section)}</h2><p>{body}</p></article>'
        )
    js = """
function copyExport() {
  const el = document.getElementById('exportText');
  if (!el) return;
  navigator.clipboard?.writeText(el.value);
}
""".strip()
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{safe_title}</title>
  <style>{CSS}</style>
</head>
<body>
  <main>
    <header>
      <div class="eyebrow">{html.escape(spec['eyebrow'])}</div>
      <h1>{safe_title}</h1>
      <p class="summary">{html.escape(spec['summary'])}</p>
    </header>
    <nav aria-label="Sections">{nav}</nav>
    <section class="grid" aria-label="Artifact sections">
      {' '.join(cards)}
    </section>
  </main>
  <script>{js}</script>
</body>
</html>
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pattern", choices=sorted(PATTERNS), required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--out", required=True, help="Output .html path")
    args = parser.parse_args()

    out = Path(args.out)
    if out.suffix.lower() != ".html":
        parser.error("--out must end with .html")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(render(args.pattern, args.title), encoding="utf-8")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
