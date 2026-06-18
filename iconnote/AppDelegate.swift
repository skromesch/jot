import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover = makePopover()
        statusItem = makeStatusItem()
    }

    // MARK: - Factory methods (internal for testability)

    func makeContextMenu() -> NSMenu {
        let menu = NSMenu()
        let aboutItem = NSMenuItem(
            title: "About iconnote",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)
        return menu
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    // MARK: - Private

    private func makePopover() -> NSPopover {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        return popover
    }

    private func makeStatusItem() -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "iconnote")
        assert(image != nil, "SF Symbol 'note.text' not found")
        item.button?.image = image
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        item.button?.action = #selector(handleClick(_:))
        item.button?.target = self
        return item
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover(relativeTo: sender)
        }
    }

    private func togglePopover(relativeTo button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showContextMenu() {
        // Set menu so NSStatusItem positions it correctly, then clear on the
        // next run loop tick so future left-clicks are not intercepted.
        statusItem.menu = makeContextMenu()
        statusItem.button?.performClick(nil)
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.menu = nil
        }
    }
}
