#!/usr/bin/env bash
# Trim the databricks-ai-dev-kit plugin's skill descriptions out of the
# available-skills metadata at SessionStart.
#
# The plugin (databricks-ai-dev-kit, currently v1.1.9) ships ~27 skill
# directories under databricks-skills/. Claude Code reads each SKILL.md
# frontmatter description into session context, so 27 skills * ~250 chars
# avg = ~7-8K chars of trigger metadata loaded every session, most of
# which never fires for Scribe work.
#
# This hook is idempotent: deletes skill dirs NOT on the KEEP list. Runs
# on every SessionStart, so plugin updates (which re-sync the marketplace
# into the cache and restore all dirs) get re-trimmed automatically. No
# need to fork the upstream plugin or maintain a marketplace.json.
#
# To bring a skill back, add its name to KEEP and start a new session.
# To revert entirely, remove this hook from settings.json SessionStart.
#
# The MCP server (databricks-mcp-server/), builder app, hooks, and
# tools-core remain untouched — every Databricks MCP tool you use today
# still works after the trim.

set -u
shopt -s nullglob

# Skills to keep. Everything else under databricks-skills/ is deleted.
# Curated for AI Scribe work (Oren Dobzinski, 2026-05-13). Verify before
# expanding: each added skill costs ~250 chars of session-start context.
KEEP=(
  databricks-docs                # fallback for uncovered topics
  databricks-config              # workspace / profile management
  databricks-execution-compute   # run code on Databricks
  databricks-jobs                # jobs management
  databricks-vector-search       # RAG indexes
  databricks-model-serving       # endpoints
  databricks-aibi-dashboards     # Lakeview dashboards
  databricks-mlflow-evaluation   # evals
  databricks-app-python          # rag-pipeline + previsit apps
  databricks-genie               # Genie spaces
  databricks-unity-catalog       # UC tables / volumes
  databricks-python-sdk          # SDK reference
  databricks-lakebase-provisioned  # Lakebase ingestion path
)

# Iterate every cached plugin version under databricks-ai-dev-kit so the
# hook keeps working after upgrades (the version dir changes on update).
for version_dir in "$HOME"/.claude/plugins/cache/databricks-ai-dev-kit/databricks-ai-dev-kit/*/databricks-skills; do
  for skill_dir in "$version_dir"/*/; do
    name=$(basename "$skill_dir")
    # Skip non-skill entries (README.md is a file; install_skills.sh too).
    [ -f "$skill_dir/SKILL.md" ] || continue
    keep=0
    for k in "${KEEP[@]}"; do
      if [ "$name" = "$k" ]; then keep=1; break; fi
    done
    if [ "$keep" = "0" ]; then
      rm -rf "$skill_dir"
    fi
  done
done

exit 0
