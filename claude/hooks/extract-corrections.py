#!/usr/bin/env python3
"""
Stop hook: scan session transcript for user corrections and remind Claude
to save them as memory entries before exiting.

Receives JSON on stdin with session_id and transcript_path.
Outputs JSON with systemMessage if corrections found.
"""

import json
import sys
import re
from pathlib import Path

# Patterns that indicate a user correction or behavioral instruction
CORRECTION_PATTERNS = [
    r'\bno[,!.]\s',           # "no, do it this way"
    r'\bwait[,!.]\s',         # "wait, don't"
    r"\bdon'?t\b",            # "don't do that"
    r'\bnever\b',             # "never commit to main"
    r'\balways\b',            # "always use --profile"
    r'\binstead\b',           # "use X instead"
    r'\bnot that\b',          # "not that way"
    r'\bwrong\b',             # "wrong file", "wrong comment"
    r'\bstop\b',              # "stop doing X"
    r'\bremember\b',          # "remember to always"
    r'\bfrom now on\b',       # "from now on, do X"
    r'\bnext time\b',         # "next time, do Y"
]

# Patterns to exclude (false positives)
EXCLUDE_PATTERNS = [
    r'^(yes|no|ok|sure|thanks)',  # simple affirmations
    r'^\s*$',                      # empty
]

def extract_corrections(transcript_path):
    """Extract user corrections from a session transcript."""
    corrections = []
    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    record = json.loads(line)
                    if record.get('type') != 'user':
                        continue
                    if record.get('isCompactSummary'):
                        continue

                    content = record.get('message', {}).get('content', '')
                    if isinstance(content, list):
                        content = ' '.join(
                            c.get('text', '') for c in content
                            if isinstance(c, dict) and c.get('type') == 'text'
                        )
                    if not isinstance(content, str) or len(content) < 15:
                        continue

                    # Check for correction patterns
                    content_lower = content.lower()
                    matched = any(
                        re.search(p, content_lower) for p in CORRECTION_PATTERNS
                    )
                    if not matched:
                        continue

                    # Exclude false positives
                    excluded = any(
                        re.match(p, content_lower) for p in EXCLUDE_PATTERNS
                    )
                    if excluded:
                        continue

                    # Keep it short for the reminder
                    corrections.append(content[:200])
                except (json.JSONDecodeError, KeyError):
                    continue
    except (FileNotFoundError, PermissionError):
        return []

    return corrections


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    transcript_path = input_data.get('transcript_path', '')
    if not transcript_path or not Path(transcript_path).exists():
        sys.exit(0)

    corrections = extract_corrections(transcript_path)

    # Only trigger if there are meaningful corrections (3+ to avoid noise)
    if len(corrections) < 3:
        sys.exit(0)

    # Sample up to 5 corrections for the reminder
    samples = corrections[:5]
    sample_text = '\n'.join(f'- "{c}"' for c in samples)
    remaining = len(corrections) - len(samples)
    if remaining > 0:
        sample_text += f'\n- ...and {remaining} more'

    message = {
        "decision": "block",
        "reason": "Corrections detected in this session",
        "systemMessage": (
            f"Before ending this session, review these {len(corrections)} "
            f"corrections you received from the user:\n\n{sample_text}\n\n"
            "If any of these represent persistent preferences or rules "
            "(not just one-time fixes), save them as memory entries or "
            "suggest adding them to CLAUDE.md. Then you may exit."
        )
    }

    json.dump(message, sys.stdout)
    sys.exit(1)  # non-zero to trigger the block


if __name__ == '__main__':
    main()
