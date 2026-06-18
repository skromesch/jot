import XCTest
import AppKit
@testable import iconnote

final class AppDelegateTests: XCTestCase {
    func test_contextMenuContainsQuitItem() {
        let delegate = AppDelegate()
        let menu = delegate.makeContextMenu()
        XCTAssertEqual(menu.items.count, 1)
        XCTAssertEqual(menu.items[0].title, "Quit")
        XCTAssertEqual(menu.items[0].keyEquivalent, "q")
        XCTAssertEqual(menu.items[0].action, #selector(NSApplication.terminate(_:)))
    }
}
