import XCTest
import AppKit
import ServiceManagement
@testable import jot

private final class FakeLoginItem: LoginItemService {
    var status: SMAppService.Status = .notRegistered
    func register() throws { status = .enabled }
    func unregister() throws { status = .notRegistered }
}

final class AppDelegateTests: XCTestCase {
    func test_contextMenuContainsAboutLaunchAtLoginAndQuit() {
        let delegate = AppDelegate()
        delegate.loginItem = FakeLoginItem()
        let items = delegate.makeContextMenu().items.filter { !$0.isSeparatorItem }
        XCTAssertEqual(items.map(\.title), ["About Jot", "Launch at Login", "Quit"])
        let quit = items[2]
        XCTAssertEqual(quit.keyEquivalent, "q")
        XCTAssertEqual(quit.action, #selector(NSApplication.terminate(_:)))
    }

    func test_launchAtLoginItemReflectsStatus() {
        let delegate = AppDelegate()
        let fake = FakeLoginItem()
        delegate.loginItem = fake
        func state() -> NSControl.StateValue {
            delegate.makeContextMenu().items.first { $0.title == "Launch at Login" }!.state
        }
        XCTAssertEqual(state(), .off)
        fake.status = .enabled
        XCTAssertEqual(state(), .on)
    }

    func test_toggleRegistersThenUnregisters() {
        let delegate = AppDelegate()
        let fake = FakeLoginItem()
        delegate.loginItem = fake
        delegate.toggleLaunchAtLogin()
        XCTAssertEqual(fake.status, .enabled)
        delegate.toggleLaunchAtLogin()
        XCTAssertEqual(fake.status, .notRegistered)
    }
}
