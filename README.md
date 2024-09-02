# QuitGuard

![QuitGuard Icon](https://github.com/adrianjagielak/QuitGuard/blob/master/QuitGuard/Assets.xcassets/AppIcon.appiconset/macOS%20icon%20256.png)

**QuitGuard** is a lightweight SwiftUI menu bar app that helps prevent accidental `Cmd+Q` presses, which can unintentionally close your entire application. This often happens due to the proximity of similar, commonly used shortcuts like `Cmd+W` (in Safari), leading to unintended app closures. QuitGuard offers a simple solution by requiring you to press and hold `Cmd+Q` to quit, minimizing the chances of these accidental exits.

## Features

- **Prevents Accidental Quits:** Instead of quitting the app immediately when `Cmd+Q` is pressed, QuitGuard requires you to hold the `Cmd+Q` combination to actually quit.
- **Menu Bar Integration:** The app runs quietly in your Mac's menu bar, allowing easy access to its settings and status.
- **Lightweight and Efficient:** Built with SwiftUI, QuitGuard is minimalistic and designed to have a small footprint on your system.

## Installation

1. Download the latest release from the [Releases](https://github.com/adrianjagielak/QuitGuard/releases) page and move it to your Applications folder.

## Usage

1. Launch QuitGuard. You will see a new icon in your menu bar.
2. Accept the system popup to grant Accessibility permissions
2. QuitGuard will start monitoring `Cmd+Q` presses.
3. To quit an app, hold down `Cmd+Q` until the app closes. If you release `Cmd+Q` too quickly, the quit command will be ignored, preventing accidental closures.

# Showcase

![QuitGuard App Store screenshot 1](https://github.com/adrianjagielak/QuitGuard/blob/master/Assets/QuitGuard%20AppStore%201.png)

![QuitGuard App Store screenshot 2](https://github.com/adrianjagielak/QuitGuard/blob/master/Assets/QuitGuard%20AppStore%202.png)

![QuitGuard App Store screenshot 3](https://github.com/adrianjagielak/QuitGuard/blob/master/Assets/QuitGuard%20AppStore%203.png)

## Contributing

Contributions are welcome! Please feel free to submit a pull request or [open an issue](https://github.com/adrianjagielak/QuitGuard/issues/new) if you have any suggestions or bug reports.
