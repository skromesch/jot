import SwiftUI

@main
struct iconnoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty Settings scene satisfies SwiftUI lifecycle requirement.
        // All UI is managed by AppDelegate via NSStatusItem + NSPopover.
        Settings { EmptyView() }
    }
}
