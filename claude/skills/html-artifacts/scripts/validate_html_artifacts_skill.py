#!/usr/bin/env python3
"""Validate the self-contained HTML Artifacts skill library.

The catalog deliberately includes two non-deliverable categories: composable PR #6 fragments
and a React/Babel reference host. This verifier checks only the templates a user may select as a
standalone, offline artifact, while still ensuring every catalog path resolves.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMPLATES = ROOT / "templates"
CATALOG = ROOT / "references" / "template-catalog.md"
CHECKER = Path(__file__).with_name("blnkoff-check_html_artifact.py")
REFERENCE_ONLY = {
    "templates/community/okminlee-4stars-jsx-host-reference-cdn.html",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def catalog_templates() -> list[str]:
    text = CATALOG.read_text(encoding="utf-8")
    paths = [
        path
        for path in re.findall(r"`(templates/[^`]+\.html)`", text)
        if "<" not in path
    ]
    if not paths:
        fail("template catalog contains no template paths")
    missing = [path for path in paths if not (ROOT / path).is_file()]
    if missing:
        fail("catalog paths missing from the skill:\n" + "\n".join(missing))
    return paths


def expected_inventory() -> None:
    official = sorted(TEMPLATES.glob("[0-9][0-9]-*.html"))
    unknowns = sorted((TEMPLATES / "unknowns").glob("*.html"))
    if len(official) != 20:
        fail(f"expected 20 official templates, found {len(official)}")
    if len(unknowns) != 12:
        fail(f"expected 12 unknowns templates including index, found {len(unknowns)}")
    for required in (ROOT / "LICENSE", ROOT / "PROVENANCE.md", CHECKER):
        if not required.is_file():
            fail(f"required file missing: {required.relative_to(ROOT)}")


def publishable_templates(catalog_paths: list[str]) -> list[Path]:
    paths = list(TEMPLATES.glob("[0-9][0-9]-*.html"))
    paths.extend((TEMPLATES / "unknowns").glob("*.html"))
    paths.extend(ROOT / path for path in catalog_paths if path not in REFERENCE_ONLY)
    paths.append(TEMPLATES / "blocks" / "thariqs-pr6-base-shell.html")
    return sorted(set(paths))


def main() -> None:
    expected_inventory()
    candidates = publishable_templates(catalog_templates())
    for candidate in candidates:
        result = subprocess.run(
            [sys.executable, str(CHECKER), str(candidate)],
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode:
            detail = (result.stdout + result.stderr).strip()
            fail(f"offline checker rejected {candidate.relative_to(ROOT)}\n{detail}")
    print(
        "ok: validated "
        f"{len(candidates)} publishable templates; "
        "catalog paths and template inventory are consistent"
    )


if __name__ == "__main__":
    main()
