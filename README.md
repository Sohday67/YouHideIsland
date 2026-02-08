# YouHideIsland

A YTLite tweak that prevents the Dynamic Island from appearing when the YouTube app is in the foreground. The Dynamic Island will only show Now Playing information when YouTube is running in the background.

## Description

When using YTLite (https://github.com/dayanch96/YTLite) with YouTube, the Dynamic Island displays Now Playing information every time a video is played. However, this behavior can be intrusive when you're actively using the app. This tweak modifies that behavior so the Dynamic Island only appears when YouTube is in the background.

## How It Works

The tweak hooks into `MPNowPlayingInfoCenter`'s `setNowPlayingInfo:` method, which is responsible for publishing media information to the system (displayed on the Dynamic Island and Lock Screen). 

- **When the app is active (foreground)**: Now Playing updates are stored but not published, preventing the Dynamic Island from showing
- **When the app transitions to background**: The stored Now Playing info is automatically published, ensuring the Dynamic Island shows correctly for background playback
- **When the app returns to foreground**: Any existing Now Playing information is cleared to immediately hide the Dynamic Island

This approach works correctly with both PIP (Picture-in-Picture) enabled and disabled scenarios.

## Requirements

- iOS 14.0 or later
- iPhone with Dynamic Island (iPhone 14 Pro and later)
- YTLite installed (https://github.com/dayanch96/YTLite)
- Jailbroken device or rootless jailbreak with tweak support

## Installation

### Using Theos

1. Clone this repository
2. Make sure you have [Theos](https://theos.dev) installed and configured
3. Run `make package` to build the .deb package
4. Install the .deb package on your device

### Manual Installation

1. Download the latest .deb file from the releases
2. Install using your preferred package manager (Filza, Sileo, Zebra, etc.)

## Building

```bash
# Clone the repository
git clone https://github.com/yourusername/YouHideIsland.git
cd YouHideIsland

# Build the package
make package
```

## Compatibility

- Works with YTLite and YouTube app
- Compatible with iOS 14.0 and later
- Designed for devices with Dynamic Island, but works on all devices (will simply prevent Now Playing info from being published in foreground)

## License

MIT License

## Credits

- Inspired by the YTLite tweak by [dayanch96](https://github.com/dayanch96/YTLite)
