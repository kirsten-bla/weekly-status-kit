#!/bin/bash
# PreToolUse hook: enforces the "Claude drafts, the user sends" guardrail in CLAUDE.md.
# Runs on every claude.ai connector tool (Gmail, Slack, Google, Jira, Calendar, Granola...).
# - deny:  anything that sends or schedules a message (except Slack to the user's own self-DM)
# - allow: read-only actions (get, list, search, read...)
# - ask:   everything else, so every write needs the user's approval

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<< "$input")

# The one send that's allowed: a Slack message to the user's own self-DM
# (used by the scheduled weekly-status run to deliver the draft).
# SLACK_SELF_DM_ID and SLACK_USER_ID come from kit.config; if they're unset, nothing is allowed.
[[ -f "$CLAUDE_PROJECT_DIR/kit.config" ]] && source "$CLAUDE_PROJECT_DIR/kit.config"
if [[ "$tool" == mcp__claude_ai_Slack__slack_send_message ]]; then
  channel=$(jq -r '.tool_input.channel_id // empty' <<< "$input")
  if [[ -n "$channel" && ( "$channel" == "$SLACK_SELF_DM_ID" || "$channel" == "$SLACK_USER_ID" ) ]]; then
    exit 0
  fi
fi

# Creating a canvas is allowed: it takes no channel or recipient, so a new canvas
# is private to the user until they share it. Editing canvases still asks.
[[ "$tool" == mcp__claude_ai_Slack__slack_create_canvas ]] && exit 0

decide() {
  jq -n --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  exit 0
}

# 1. Sending is never allowed.
case "$tool" in
  mcp__claude_ai_Gmail__send_message|mcp__claude_ai_Gmail__reply|mcp__claude_ai_Gmail__forward|\
  mcp__claude_ai_Slack__slack_send_message|mcp__claude_ai_Slack__slack_schedule_message)
    decide deny "Blocked by workspace guardrail: Claude never sends, forwards, replies or schedules messages. Show the text for the user to send." ;;
esac

# 2. Reads pass through. Action = part after the last "__", minus a "slack_" prefix.
action=${tool##*__}
action=${action#slack_}
case "$action" in
  get*|list*|search*|read*|query*|fetch*|lookup*|download*|suggest*|guide|atlassianUserInfo)
    exit 0 ;;
esac

# 3. Anything else writes something: ask first.
decide ask "Workspace guardrail: this writes to an external tool. Approve only if you accepted the content."
