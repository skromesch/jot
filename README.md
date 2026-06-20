# Jot

A minimal macOS menubar app for quick rich-text notes.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

Jot lives in your menubar and opens instantly whenever you need to jot something down. It supports basic rich-text formatting so your notes can be more than just plain text — without getting in the way.

Notes are session-only and not saved to disk, making Jot ideal for temporary scratchpad use.

## Features

- **Rich text editing** — bold, italic, underline, strikethrough
- **Lists** — bullet lists, numbered lists, and interactive checkboxes
- **Font size adjustment** — increase or decrease text size via toolbar buttons
- **Keyboard shortcuts** — all formatting operations have shortcuts (see below)
- **Inline help** — press `?` in the toolbar to toggle the help panel
- **Minimal UI** — no Dock icon, no windows, just a menubar popover

## Requirements

- macOS 13.0 or later
- Xcode 15 or later (to build from source)

## Installation

### Build from source

1. Clone the repository:
   ```bash
   git clone https://github.com/skromesch/jot.git
   cd jot
   ```

2. Open `iconnote.xcodeproj` in Xcode.

3. Select your development team in **Signing & Capabilities** if needed.

4. Build and run with `⌘R`.

The app will appear in your menubar after launch.

## Usage

- **Left-click** the menubar icon to open or close the note popover.
- **Right-click** the menubar icon for the context menu (About, Quit).
- Click anywhere outside the popover to dismiss it. Your text remains until you quit the app or clear it manually.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘B` | Bold |
| `⌘I` | Italic |
| `⌘U` | Underline |
| `⌘⇧X` | Strikethrough |
| `⌘⇧L` | Bullet list |
| `⌘⇧O` | Numbered list |
| `⌘⇧K` | Checkbox |
| `⌘Q` | Quit |

Font size is adjusted via the toolbar buttons only (`A-` / `A+`). All shortcuts use physical key positions and work correctly on non-QWERTY layouts (e.g. Hungarian QWERTZ).

## Project Structure

```
iconnote/
├── iconnoteApp.swift       # App entry point
├── AppDelegate.swift       # NSStatusItem, popover, right-click menu
├── ContentView.swift       # Root SwiftUI view, state management
├── RichTextEditor.swift    # NSTextView subclass + NSViewRepresentable wrapper
├── FormatToolbar.swift     # Formatting toolbar UI
├── HelpView.swift          # Inline help panel
└── Assets.xcassets/        # App icon
```

## Architecture

Jot is a standard macOS `LSUIElement` app (no Dock icon). The menubar icon is managed by `AppDelegate` via `NSStatusItem`. The popover contains a SwiftUI view hierarchy.

Rich text editing is handled by `RichNSTextView`, a subclass of `NSTextView`, which overrides `keyDown` and `mouseDown` to handle formatting shortcuts and checkbox toggling. The SwiftUI binding uses a generation counter to avoid clobbering the text view's state on re-renders.

## License

MIT License — see [LICENSE](LICENSE) for details.
