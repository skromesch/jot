import XCTest
import SwiftUI
@testable import jot

final class ContentViewTests: XCTestCase {
    func test_attributedTextStateExists() {
        let view = ContentView()
        let mirror = Mirror(reflecting: view)
        // SwiftUI exposes @State storage as "_name" (older SDKs) or "__name" (newer ones).
        let textState = mirror.children.first(where: { $0.label?.hasSuffix("_attributedText") == true })
        XCTAssertNotNil(textState, "ContentView must have a @State var named 'attributedText'")
    }
}
