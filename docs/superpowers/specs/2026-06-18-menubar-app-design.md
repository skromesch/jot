# iconnote — Menu Bar Quick Note App Design

**Date:** 2026-06-18  
**Tech:** Swift / SwiftUI, macOS 13+ (Ventura)  
**Scope:** Single-window menu bar app for quick, session-only text notes

---

## Overview

A macOS menu bar application that displays a `note.text` SF Symbol icon in the system status bar. Clicking the icon opens a popover window containing a full-size `TextEditor`. Notes are session-only — text is lost when the app quits. The app does not appear in the Dock.

---

## Architecture

Single Xcode project using SwiftUI App lifecycle with `MenuBarExtra` (macOS 13+). No persistence layer. State lives in `ContentView` as a plain `@State` variable.

```
iconnote/
├── iconnote.xcodeproj
└── iconnote/
    ├── iconnoteApp.swift   — app entry point, MenuBarExtra declaration
    ├── ContentView.swift   — TextEditor UI
    └── Info.plist          — LSUIElement = YES (no Dock icon)
```

---

## Components

### `iconnoteApp.swift`
- Declares `MenuBarExtra` with label `"iconnote"` and SF Symbol `note.text`
- Uses `.menuBarExtraStyle(.window)` so a proper popover window appears (not a menu)
- `ContentView` is the body of the `MenuBarExtra`

### `ContentView.swift`
- Single `TextEditor` bound to `@State var text: String = ""`
- Fixed frame: 320 × 400 pt
- No toolbar, no buttons — just the editor

### `Info.plist`
- `LSUIElement` = `YES` — suppresses the Dock icon and App Switcher entry

---

## Behavior

- Left-click menu bar icon → popover opens
- Click anywhere outside the popover → popover closes (native macOS behavior)
- Right-click (secondary click) menu bar icon → context menu appears with:
  - **Quit** — terminates the app (keyboard shortcut: ⌘Q)
- Quit app → text is discarded (no persistence)
- macOS requirement: Ventura (13.0) or later

### Context Menu Implementation Note

`MenuBarExtra` with `.window` style does not natively support a separate right-click menu. The right-click context menu requires intercepting the `NSStatusBarButton`'s secondary mouse-up event via AppKit (`NSStatusItem` access through `NSStatusBar.system`), then calling `NSMenu.popUpContextMenu(_:with:for:)`. This bridges AppKit into the SwiftUI app entry point.

---

## Out of Scope

- Text persistence (UserDefaults, file, iCloud)
- Multiple notes
- Formatting, markdown, rich text
- Keyboard shortcut to open/close
