# Design Tokens

The shared palette and type system behind the official `templates/`. Declare these in
`:root` and reuse them — don't invent colors or fonts mid-document. Read this when you need
a palette beyond what a template already sets: a dark variant, a brand palette, or print.

Adapted from the `aletuan` fork of `html-effectiveness` (Apache-2.0; see `PROVENANCE.md`).
The community lane does **not** follow this system — these tokens describe `templates/` and
`templates/unknowns/`.

## Palette (light — the default)

```css
:root {
  /* Surfaces */
  --ivory:    #FAF9F5;  /* page background */
  --paper:    #FFFFFF;  /* cards, panels */
  --oat:      #E3DACC;  /* subtle fills, avatars */

  /* Text */
  --slate:    #141413;  /* primary text, headings */
  --gray-700: #3D3D3A;  /* body text */
  --gray-500: #87867F;  /* secondary / meta */
  --gray-300: #D1CFC5;  /* borders */
  --gray-200: #E6E3DA;  /* light borders, dividers */
  --gray-150: #F0EEE6;  /* hover, table stripes */

  /* Accents */
  --clay:     #D97757;  /* primary accent, links, eyebrows */
  --clay-d:   #B85C3E;  /* clay pressed/dark */
  --olive:    #788C5D;  /* success, additions, positive */
  --rust:     #B04A3F;  /* warning, deletions, danger */
}
```

## Dark variant

Artifacts default to **light**. Produce dark only when the user asks for it — there's no
`prefers-color-scheme` auto-switching, because an artifact that silently changes appearance
is harder to reason about when someone screenshots it into a ticket.

Token **names stay identical**; only values change, so every structural rule (hairlines,
radius, serif/sans/mono roles) carries over untouched.

1. Use the dark values below in `:root` instead of the light ones.
2. Add `color-scheme: dark;` to `:root` **and** `<meta name="color-scheme" content="dark">`
   in `<head>`. This self-declares the mode, so a later reader — human or agent — knows
   which mode the file is in without parsing CSS.
3. Keep everything else identical: same structure, same hairlines, same sparing color.

```css
:root {
  color-scheme: dark;

  /* Surfaces — warm dark, not pure black */
  --ivory:    #1A1916;  /* page background  (light: #FAF9F5) */
  --paper:    #24221E;  /* cards, panels    (light: #FFFFFF) */
  --oat:      #3A352D;  /* subtle fills     (light: #E3DACC) */

  /* Text — warm off-white, not pure white */
  --slate:    #ECEAE3;  /* primary text     (light: #141413) */
  --gray-700: #C9C6BD;  /* body text        (light: #3D3D3A) */
  --gray-500: #9C988D;  /* secondary / meta (light: #87867F) */
  --gray-300: #3D3A33;  /* borders          (light: #D1CFC5) */
  --gray-200: #332F29;  /* dividers         (light: #E6E3DA) */
  --gray-150: #211F1B;  /* hover, stripes   (light: #F0EEE6) */
  --white:    #24221E;  /* alias → paper    (light: #FFFFFF) */

  /* Accents — same hue, lifted ~12% for contrast on dark */
  --clay:     #E08A6B;  /* accent, links    (light: #D97757) */
  --clay-d:   #C9714F;  /* clay pressed     (light: #B85C3E) */
  --olive:    #9DB07E;  /* success, +       (light: #788C5D) */
  --rust:     #CE6B5B;  /* danger, −        (light: #B04A3F) */
}
```

For diff tints on dark, use the accent at low alpha — `rgba(157,176,126,0.16)` for
additions, `rgba(206,107,91,0.16)` for deletions — rather than flat light-mode fills.

## Typography

```css
:root {
  --serif: ui-serif, Georgia, "Times New Roman", Times, serif;
  --sans:  system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --mono:  ui-monospace, "SF Mono", Menlo, Monaco, Consolas, monospace;
}
```

**Roles:**
- **Serif** — page title (h1) and major section titles. Weight 500, never bold. Slightly
  negative letter-spacing at large sizes.
- **Sans** — body, UI chrome, buttons, table cells.
- **Mono** — eyebrows (uppercase 12px, `0.12em` letter-spacing), IDs, code, file paths,
  dates, tag labels.

**Rough size scale:**
- Hero h1: `clamp(38px, 5.4vw, 62px)`, line-height ~1.06
- Doc h1: 28–32px serif weight 500
- Section h2: 18–22px
- Body: 15–16.5px sans
- Meta / eyebrow: 12–13px mono

## Layout

- Page background `var(--ivory)`; content max-width 920–1120px (reports tighter, galleries wider)
- Document padding `48px 24px 80px`; masthead style `80px 0 56px` for landing pages
- Cards: `1.5px solid var(--gray-300)`, `border-radius: 12px`, `var(--paper)` background,
  24–32px internal padding

## Visual rules

- Hairlines are **1.5px**, not 1px — this is what produces the warm-paper feel.
- Radius **10–12px** on cards, **6–8px** on inline chips/buttons. Never sharp, rarely pill.
- Use color sparingly. One clay underline or olive dot does more work than a filled button;
  most surfaces stay ivory/paper.
- Diff red/green uses `--rust` / `--olive`, never pure red/green.
- Avoid drop shadows — borders plus subtle background tints instead. Avoid gradients.

## Print / PDF

Document-shaped artifacts should "Save as PDF" cleanly, because they get mailed to people
who never open the `.html`. **None of the bundled official templates carry a print block**
(only `templates/blocks/thariqs-pr6-base-shell.html` and four `zakelfassi` community files
have any `@media print` at all, and base-shell's is three rules). So add it yourself: paste
`assets/print.html` into the artifact's `<style>`.

Worth doing for document shapes — `03`, `04`, `11`, `12`, `14`, `15`, `16`, `17`, and
composed block reports. Skip it for editors (`18`–`20`) and prototypes (`07`–`08`), where
printing an interactive tool is meaningless.

`assets/print.html` carries its own integration notes, the `.no-print` /
`.no-print-sticky` conventions, and the dark-mode caveat.

## When the user wants a different palette

For **dark**, use the canonical dark token set above — don't improvise new dark values. For
other requests (brand colors, "blue theme"), adapt the tokens but keep the structural rules:
hairline widths, radius, serif/sans/mono roles, layout density. The look comes from the
system, not just the colors. See also "Matching the host project's style" in `SKILL.md`.
