#!/bin/bash
# Installs the Friday 4 pm launchd job for this checkout (macOS).
# Usage: scripts/install-schedule.sh          install or reinstall
#        scripts/install-schedule.sh --remove  stop and remove it

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LABEL=com.weekly-status-kit
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
if [[ "$1" == --remove ]]; then
  rm -f "$PLIST" && echo "Removed $LABEL."
  exit 0
fi

"$REPO/scripts/check-config.sh" --scheduled || exit 1
mkdir -p "$REPO/drafts/logs" "$HOME/Library/LaunchAgents"
sed -e "s#__REPO__#$REPO#g" -e "s#__HOME__#$HOME#g" -e "s#__LABEL__#$LABEL#g" \
  "$REPO/scripts/weekly-status.plist.template" > "$PLIST"
launchctl bootstrap "gui/$(id -u)" "$PLIST" && echo "Installed $LABEL: Fridays at 4 pm."
echo "Test it now: launchctl kickstart gui/$(id -u)/$LABEL"
