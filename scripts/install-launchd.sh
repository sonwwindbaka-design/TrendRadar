#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="com.lunmin.trendradar"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
RUNNER="$PROJECT_ROOT/scripts/run-trendradar-launchd.sh"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"
chmod +x "$RUNNER"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>$RUNNER</string>
  </array>

  <key>WorkingDirectory</key>
  <string>$PROJECT_ROOT</string>

  <key>StartCalendarInterval</key>
  <array>
    <dict>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>33</integer>
    </dict>
    <dict>
      <key>Hour</key>
      <integer>20</integer>
      <key>Minute</key>
      <integer>33</integer>
    </dict>
  </array>

  <key>StandardOutPath</key>
  <string>$LOG_DIR/launchd.out.log</string>

  <key>StandardErrorPath</key>
  <string>$LOG_DIR/launchd.err.log</string>

  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST

plutil -lint "$PLIST"

if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
  launchctl bootout "gui/$(id -u)" "$PLIST"
fi

launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"

echo "Installed $LABEL"
echo "Plist: $PLIST"
echo "Schedule: 08:33 and 20:33 local time"
echo "Run now: launchctl kickstart -k gui/$(id -u)/$LABEL"
