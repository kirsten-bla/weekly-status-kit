#!/bin/bash
# PreToolUse hook: denies reading or editing secrets (.env files, keys, credentials),
# whichever file tool or shell command tries it. kit.config holds IDs, not secrets, so it's allowed.

input=$(cat)
target=$(jq -r '[.tool_input.file_path, .tool_input.path, .tool_input.glob, .tool_input.command] | map(select(. != null)) | join(" ")' <<< "$input")

if grep -qiE '(^|[[:space:]/"'\''=])\.env([.[:space:]/"'\'']|$)|\.(pem|p12|pfx|key)([[:space:]"'\'']|$)|id_(rsa|ed25519)|credentials|\.netrc' <<< "$target"; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: "Blocked by workspace guardrail: this kit never reads or edits secrets (.env, keys, credentials)."}}'
fi
exit 0
