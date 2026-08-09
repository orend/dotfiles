#!/usr/bin/env python3
"""Check a self-contained HTML-effectiveness artifact for common issues."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ERRORS: list[str] = []
WARNINGS: list[str] = []


def error(msg: str) -> None:
    ERRORS.append(msg)


def warn(msg: str) -> None:
    WARNINGS.append(msg)


def check(content: str) -> None:
    lower = content.lower()

    if "<html" not in lower:
        error("missing <html> element")
    if "<!doctype html" not in lower[:200]:
        warn("missing <!doctype html> near the top")
    if "<title" not in lower:
        error("missing <title>")
    if "name=\"viewport\"" not in lower and "name='viewport'" not in lower:
        error("missing responsive viewport meta tag")
    if "<style" not in lower:
        warn("no inline <style>; artifact may be visually under-structured")

    external_script = re.findall(r"<script\b[^>]*\bsrc\s*=\s*['\"]([^'\"]+)", content, re.I)
    external_css = re.findall(r"<link\b[^>]*\brel\s*=\s*['\"]stylesheet['\"][^>]*\bhref\s*=\s*['\"]([^'\"]+)", content, re.I)
    external_media = re.findall(r"<(?:img|iframe|video|audio)\b[^>]*\bsrc\s*=\s*['\"](https?://[^'\"]+)", content, re.I)
    for src in external_script:
        error(f"external script dependency: {src}")
    for href in external_css:
        error(f"external stylesheet dependency: {href}")
    for src in external_media:
        warn(f"external media dependency: {src}")

    if re.search(r"https?://", content) and not (external_script or external_css or external_media):
        warn("contains external URLs; verify they are citations/links, not required assets")

    interactive_words = re.search(r"\b(drag|drop|slider|toggle|editor|textarea|input|select|contenteditable|tune|reorder)\b", lower)
    export_words = re.search(r"\b(copy|export|download|diff|json|markdown|prompt|clipboard)\b", lower)
    if interactive_words and not export_words:
        warn("interactive/editor-like artifact has no obvious copy/export path")

    if len(content) < 1500:
        warn("very small file; ensure HTML adds value over Markdown")
    if "aria-label" not in lower and "<button" in lower:
        warn("buttons present but no aria-label found; check accessibility labels manually")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("html_file")
    args = parser.parse_args()

    path = Path(args.html_file)
    if not path.exists():
        print(f"error: file not found: {path}", file=sys.stderr)
        return 2
    content = path.read_text(encoding="utf-8", errors="replace")
    check(content)

    if ERRORS:
        print("ERRORS:")
        for item in ERRORS:
            print(f"- {item}")
    if WARNINGS:
        print("WARNINGS:")
        for item in WARNINGS:
            print(f"- {item}")
    if not ERRORS and not WARNINGS:
        print("ok: no common issues found")
    elif not ERRORS:
        print("ok with warnings")
    return 1 if ERRORS else 0


if __name__ == "__main__":
    raise SystemExit(main())
