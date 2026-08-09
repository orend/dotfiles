# Quality Checklist

Use before delivering substantial HTML artifacts.

## Required checks

- The artifact has a clear job: decision, review, learning, report, prototype, or editing.
- The first screen tells the reader what this is and what to do next.
- Long pages include navigation or a visible section structure.
- Comparisons are side by side.
- Code/diffs preserve line-level readability.
- Diagrams explain relationships that would be hard to hold in prose.
- Color has semantic meaning and is not the only way meaning is conveyed.
- Interactive elements have labels, keyboard-friendly controls where practical, and visible state.
- Editors include copy/export output.
- Assumptions, source material, and fictional/sample data are labeled.
- The file is self-contained unless the user explicitly accepted dependencies.
- It is usable on mobile and desktop.

## Fast verification with script

When tools are available:

```bash
python scripts/check_html_artifact.py path/to/artifact.html
```

Fix all errors. Warnings are judgment calls, but do not ignore warnings about external dependencies, missing viewport, or missing export path in editors.

## Pressure-test prompts

Use these to catch weak artifacts:

1. **Skim test:** “Can a busy reviewer understand the point in 30 seconds?” If not, improve TL;DR, headings, and visual hierarchy.
2. **Decision test:** “What decision/action does this page enable?” If unclear, add a recommendation, options, or next steps.
3. **Round-trip test:** “After interacting, how does the user's choice get back to the agent/codebase?” If unclear, add copy/export.
4. **Trust test:** “Which facts are sourced, inferred, or fictional?” If unclear, label provenance.
5. **Portability test:** “Can this file be opened from disk in a browser?” If not, inline or remove dependencies.
