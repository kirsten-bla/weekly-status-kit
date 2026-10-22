#!/bin/zsh
# Runs /weekly-status headless (draft only). The run itself sends the draft to the
# user's Slack self-DM; if it fails, this script sends a short failure message there.
# Started every Friday at 4 pm by the launchd job that scripts/install-schedule.sh installs.
# The draft lands in drafts/weekly-status-<meeting date>.md; the log in drafts/logs/.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO/drafts/logs"
LOG="$LOG_DIR/weekly-status-$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"
cd "$REPO" || exit 1
if ! "$REPO/scripts/check-config.sh" --scheduled >> "$LOG" 2>&1; then
  osascript -e 'display notification "Kit not configured, see drafts/logs" with title "Weekly status"'
  exit 1
fi
source "$REPO/kit.config"
CLAUDE="${CLAUDE_BIN:-$HOME/.local/bin/claude}"

START_MARK="$LOG_DIR/.run-start"
touch "$START_MARK"
# Start from an empty working folder (the headless run can't clean up after itself).
rm -rf "$REPO/drafts/weekly-status-work"

# Read-only connector tools, plus file tools for the working folder, the draft and the run log.
# Anything not listed is denied, since no one is there to approve it.
ALLOWED=(
  Agent Read Write Edit Glob Grep
  "Bash(mkdir -p drafts/*)" "Bash(rm -rf drafts/weekly-status-work)"
  "Bash(scripts/check-config.sh --scheduled)"
  mcp__claude_ai_Google_Drive__read_file_content
  mcp__claude_ai_Atlassian_MCP__getAccessibleAtlassianResources
  mcp__claude_ai_Atlassian_MCP__searchJiraIssuesUsingJql
  mcp__claude_ai_Atlassian_MCP__getJiraIssue
  mcp__claude_ai_Gmail__search_threads
  mcp__claude_ai_Gmail__get_thread
  mcp__claude_ai_Slack__slack_read_channel
  mcp__claude_ai_Slack__slack_read_thread
  mcp__claude_ai_Granola__list_meeting_folders
  mcp__claude_ai_Granola__list_meetings
  mcp__claude_ai_Granola__get_meetings
  mcp__claude_ai_Granola__get_meeting_transcript
  mcp__claude_ai_Slack__slack_send_message   # the hook only lets this reach the self-DM
  mcp__claude_ai_Slack__slack_create_canvas  # private to the user until shared
)

{
  echo "=== $(date) start"
  "$CLAUDE" -p "/weekly-status

This is a scheduled run: follow the skill's scheduled-run instructions." \
    --allowedTools "${ALLOWED[@]}"
  rc=$?
  echo "=== $(date) end (exit $rc)"
} >> "$LOG" 2>&1

# Only count a draft written during this run.
draft=$(find "$REPO/drafts" -maxdepth 1 -name 'weekly-status-*.md' -newer "$START_MARK" 2>/dev/null | head -1)
if [[ $rc -ne 0 || -z "$draft" ]]; then
  # The run didn't produce a draft, so it never sent one. Tell the user on Slack,
  # and fall back to a Mac notification if that fails too.
  "$CLAUDE" -p "Send this exact Slack message to channel_id $SLACK_SELF_DM_ID and nothing else: 'Weekly status scheduled run failed ($(date '+%a %b %d, %H:%M')). See drafts/logs/$(basename "$LOG") on the Mac.'" \
    --allowedTools mcp__claude_ai_Slack__slack_send_message >> "$LOG" 2>&1 ||
    osascript -e 'display notification "Run failed, see drafts/logs" with title "Weekly status"'
fi
