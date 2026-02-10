# notsora

A native macOS video compressor built with SwiftUI. Drag in videos, tweak codec/quality/metadata settings, and batch-compress with real-time progress tracking.

Styled after Twitter's Bowman-era (2009-2014) visual design: clean whites, sky blues, light grays, and generous whitespace.

## Requirements

- macOS 14.0+
- Swift 5.9+ (Xcode 15.4+ or standalone Swift toolchain)
- ffmpeg and ffprobe binaries

## Building

### Quick build (Swift Package Manager)

```bash
swift build -c release
```

The binary lands at `.build/release/notsora`.

### Creating the app bundle

After building, assemble `notsora.app` manually:

```bash
# Create bundle structure
mkdir -p build/notsora.app/Contents/{MacOS,Resources,Frameworks}

# Copy the binary
cp .build/release/notsora build/notsora.app/Contents/MacOS/notsora

# Copy ffmpeg binaries into Resources
cp /opt/homebrew/bin/ffmpeg build/notsora.app/Contents/Resources/ffmpeg
cp /opt/homebrew/bin/ffprobe build/notsora.app/Contents/Resources/ffprobe
chmod +x build/notsora.app/Contents/Resources/ffmpeg
chmod +x build/notsora.app/Contents/Resources/ffprobe
```

Create `build/notsora.app/Contents/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>notsora</string>
    <key>CFBundleIdentifier</key>
    <string>com.notsora.app</string>
    <key>CFBundleName</key>
    <string>notsora</string>
    <key>CFBundleDisplayName</key>
    <string>notsora</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
```

Ad-hoc sign and run:

```bash
codesign --force --deep --sign - build/notsora.app
open build/notsora.app
```

### Building with Xcode

Open `notsora.xcodeproj` and build/run the `notsora` target (Cmd+R).

### ffmpeg dependency

notsora needs `ffmpeg` and `ffprobe` at runtime. It checks these locations in order:

1. App bundle: `notsora.app/Contents/Resources/ffmpeg`
2. Homebrew (Apple Silicon): `/opt/homebrew/bin/ffmpeg`
3. Homebrew (Intel): `/usr/local/bin/ffmpeg`

For development, install via Homebrew and the app will find them automatically:

```bash
brew install ffmpeg
```

For distribution, bundle the binaries (and their dylib dependencies) inside the app.

## Features

- Batch compression with per-file settings
- Video codecs: H.264, H.265 (HEVC)
- Audio codecs: AAC, Opus
- Quality modes: CRF (constant quality) or target bitrate
- Resolution scaling (original, 1080p, 720p, 480p)
- Encoding presets (ultrafast through veryslow)
- Container formats: MP4, MKV, WebM
- Metadata editor with custom tag support
- Real-time progress with ETA
- Drag-and-drop file import

## Supported input formats

MP4, MOV, AVI, MKV, WMV, FLV, WebM, M4V, MPG, MPEG, 3GP, TS, MTS

## Project structure

```
notsora/
  App/             Entry point and constants
  Models/          Data types and enums
  ViewModels/      Observable state management
  Views/
    Sidebar/       File list and row views
    Detail/        Settings forms
    Progress/      Compression progress UI
    Shared/        Theme colors and reusable components
  Services/        FFmpeg integration
  Resources/       Asset catalogs
```

## License

MIT
