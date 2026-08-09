#!/usr/bin/env node
import { readFileSync } from 'node:fs';

const path = process.argv[2];
if (!path) { console.error('Usage: node validate-html.mjs <file.html>'); process.exit(1); }

const html = readFileSync(path, 'utf-8');
let errors = 0;
let warnings = 0;

function fail(type, msg) {
  console.log(`  ${type === 'ERR' ? '✖' : '⚠'}  [${type}] ${msg}`);
  type === 'ERR' ? errors++ : warnings++;
}

function parseNum(s) { const v = parseFloat(s); return isNaN(v) ? null : v; }

function textWidth(text, fontSize, fontFamily) {
  const CW = { mono: 0.62, sans: 0.55, serif: 0.52, def: 0.55 };
  let cw = CW.def;
  if (/mono/i.test(fontFamily)) cw = CW.mono;
  else if (/serif/i.test(fontFamily)) cw = CW.serif;
  else if (/sans|system-ui/i.test(fontFamily)) cw = CW.sans;
  return text.length * cw * fontSize;
}

// ── 1. SVG text with HTML tags ──
for (const t of html.match(/<text[^>]*>.*?<\/text>/gs) || []) {
  const raw = t.match(/<text[^>]*>([\s\S]*?)<\/text>/)[1];
  if (/<[a-z]+[ >]/.test(raw) && !/<tspan/.test(raw))
    fail('ERR', `SVG <text> contains HTML tag: "${raw.slice(0, 60)}..."`);
  const inside = t.replace(/<[^>]+>/g, '').trim();
  if (!inside) fail('WARN', 'SVG <text> appears empty');
}

// ── 2. Annotation overlapping arrows ──
const labelY = [...html.matchAll(/class="sub"[^>]*y="(\d+)"/g)].map(m => +m[1]);
const arrowY = [...html.matchAll(/class="arrow"[^>]*y1="(\d+)"/g)].map(m => +m[1]);
for (const ly of labelY) for (const ay of arrowY)
  if (Math.abs(ly - ay) < 6)
    fail('WARN', `Annotation at y=${ly} overlaps arrow at y=${ay}`);

// ── 3. Dark mode specificity ──
if (html.includes('prefers-color-scheme: dark') &&
    html.includes('class="dark-mode"') &&
    !html.includes('html[data-dm=') && !html.includes('html.dark-mode'))
  fail('WARN', 'Uses .dark-mode class without html[data-dm] — may be overridden by @media');

// ── 4. Matching SVG/Details tags ──
const svgO = (html.match(/<svg[\s>]/g) || []).length;
const svgC = (html.match(/<\/svg>/g) || []).length;
if (svgO !== svgC) fail('ERR', `SVG: ${svgO} opens, ${svgC} closes`);

const detO = (html.match(/<details[\s>]/g) || []).length;
const detC = (html.match(/<\/details>/g) || []).length;
if (detO !== detC) fail('ERR', `<details>: ${detO} opens, ${detC} closes`);

// ── 5. JS onclick references exist ──
const onClickFns = [...new Set([...html.matchAll(/onclick="(\w+)\(/g)].map(m => m[1]))];
for (const fn of onClickFns)
  if (!html.includes(`function ${fn}(`))
    fail('ERR', `onclick="${fn}()" but no function ${fn} defined`);

// ── 6. SVG text overflow ──
// Uses nearest-rect matching: for each text, find the rect with the MOST
// horizontal overlap (the visual container), then check overflow against only that rect.
for (const [fullSvg, vbStr, content] of html.matchAll(/<svg[^>]*viewBox="([^"]*)"[^>]*>([\s\S]*?)<\/svg>/g)) {
  const vbParts = vbStr.trim().split(/\s+/);
  if (vbParts.length < 4) continue;
  const vbW = parseInt(vbParts[2], 10);
  const vbH = parseInt(vbParts[3], 10);
  if (!vbW || !vbH) continue;

  // Collect rects
  const rects = [];
  for (const rm of content.matchAll(/<rect[^>]*>/g)) {
    const r = { x: 0, y: 0, w: 0, h: 0 };
    const rx = rm[0].match(/x="([^"]*)"/);  if (rx) r.x = parseNum(rx[1]) || 0;
    const ry = rm[0].match(/y="([^"]*)"/);  if (ry) r.y = parseNum(ry[1]) || 0;
    const rw = rm[0].match(/width="([^"]*)"/); if (rw) r.w = parseNum(rw[1]) || 0;
    const rh = rm[0].match(/height="([^"]*)"/); if (rh) r.h = parseNum(rh[1]) || 0;
    if (r.w > 0 && r.h > 0) rects.push(r);
  }

  // Process text blocks
  for (const tb of content.matchAll(/<text[^>]*>[\s\S]*?<\/text>/g)) {
    const h = tb[0];
    const xa = h.match(/x="([^"]*)"/); if (!xa) continue;
    const xVal = parseNum(xa[1]); if (xVal === null) continue;
    const ya = h.match(/y="([^"]*)"/);
    const yVal = ya ? parseNum(ya[1]) || 0 : 0;
    const anchor = (h.match(/text-anchor="([^"]*)"/) || [, 'start'])[1];
    const fs = parseInt((h.match(/font-size="(\d+)"/) || [, '12'])[1], 10) || 12;
    const ff = (h.match(/font-family="([^"]*)"/) || [, 'sans'])[1];

    // Extract lines (handle tspans)
    const lines = [];
    const tspans = [...h.matchAll(/<tspan[^>]*>([\s\S]*?)<\/tspan>/g)];
    if (tspans.length) {
      for (const ts of tspans) {
        const t = ts[1].replace(/<[^>]+>/g, '').trim();
        if (t) lines.push(t);
      }
    } else {
      const d = h.replace(/<[^>]+>/g, '').trim();
      if (d) lines.push(d);
    }

    for (const line of lines) {
      const tw = textWidth(line, fs, ff);
      let left, right;
      if (anchor === 'middle') { left = xVal - tw/2; right = xVal + tw/2; }
      else if (anchor === 'end') { left = xVal - tw; right = xVal; }
      else { left = xVal; right = xVal + tw; }

      // ── Check viewBox clipping ──
      const vL = Math.max(0, Math.round(-left));
      const vR = Math.max(0, Math.round(right - vbW));
      if (vL > 2 || vR > 2) {
        const s = [];
        if (vL > 2) s.push(`left ${vL}px`);
        if (vR > 2) s.push(`right ${vR}px`);
        fail('ERR', `SVG text clipped by viewBox (${s.join(', ')}): "${line.slice(0, 50)}..."`);
      }

      // ── Check rect overflow (nearest-rect matching) ──
      // Find the rect with the most horizontal overlap
      let bestOverlap = 0;
      let bestRect = null;
      for (const r of rects) {
        if (yVal < r.y - 10 || yVal > r.y + r.h + 10) continue;
        const overlap = Math.min(right, r.x + r.w) - Math.max(left, r.x);
        if (overlap > bestOverlap) {
          bestOverlap = overlap;
          bestRect = r;
        }
      }

      if (bestRect) {
        const rL = bestRect.x;
        const rR = bestRect.x + bestRect.w;
        const oL = Math.max(0, Math.round(rL - left));
        const oR = Math.max(0, Math.round(right - rR));

        if (oL > 2 || oR > 2) {
          const s = [];
          if (oL > 2) s.push(`left ${oL}px`);
          if (oR > 2) s.push(`right ${oR}px`);
          // Only flag if text primarily belongs to this rect (>50% overlap)
          const textArea = right - left;
          const overlapRatio = bestOverlap / textArea;
          if (overlapRatio > 0.3) {
            fail('WARN', `SVG text overflows container rect (${s.join(', ')}): "${line.slice(0, 50)}..."`);
          }
        }
      }
    }
  }
}

// ── 7. Universal reset list gotcha ──
if (/\*\{[^}]*padding:\s*0/.test(html)) {
  if (/<ol[\s>]/.test(html) && !/ol\s*\{[^}]*padding-left/.test(html))
    fail('WARN', 'Universal reset `padding:0` but <ol> used without `ol { padding-left: ... }`');
}

console.log(`\n${errors + warnings} issues found (${errors} errors, ${warnings} warnings).`);
process.exit(errors > 0 ? 1 : 0);
