#!/bin/bash
# Checks the kit is configured: kit.config has every required value, and the
# local files exist. Prints OK, or what is missing. The skill runs this first.
# Usage: scripts/check-config.sh [--scheduled]

REPO="$(cd "$(dirname "$0")/.." && pwd)"
REFS="$REPO/.claude/skills/weekly-status/references"
missing=()

if [[ ! -f "$REPO/kit.config" ]]; then
  missing+=("kit.config: file missing (copy kit.config.example to kit.config)")
else
  source "$REPO/kit.config"
  required=(STATUS_DOC_ID CLIENT_NAME JIRA_SITE JIRA_PROJECT JIRA_SPRINT_FIELD GMAIL_LABEL SLACK_CHANNEL_ID GRANOLA_FOLDER_ID)
  [[ "$1" == --scheduled ]] && required+=(SLACK_SELF_DM_ID CLAUDE_BIN)
  for key in "${required[@]}"; do
    [[ -z "${!key}" ]] && missing+=("kit.config: $key is empty")
  done
fi

[[ -f "$REFS/items.md" ]] || missing+=("references/items.md: file missing (copy items.example.md and list your items)")
[[ -f "$REFS/client-rules.md" ]] || missing+=("references/client-rules.md: file missing (copy client-rules.example.md)")
grep -qs '| EXAMPLE:' "$REFS/items.md" && missing+=("references/items.md: still has the EXAMPLE rows")

if (( ${#missing[@]} )); then
  echo "NOT CONFIGURED"
  printf -- '- %s\n' "${missing[@]}"
  echo "See README.md → Configure before your first run."
  exit 1
fi
echo "OK"
