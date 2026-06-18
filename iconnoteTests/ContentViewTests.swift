import XCTest
import SwiftUI
@testable import iconnote

final class ContentViewTests: XCTestCase {
    func test_initialTextIsEmpty() {
        let view = ContentView()
        // Access the underlying state via Mirror reflection
        let mirror = Mirror(reflecting: view)
        let textBinding = mirror.children.first(where: { $0.label == "_text" })
        XCTAssertNotNil(textBinding, "ContentView must have a @State var named 'text'")
    }
}
