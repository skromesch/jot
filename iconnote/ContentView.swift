import SwiftUI

struct ContentView: View {
    @State private var text = ""

    var body: some View {
        TextEditor(text: $text)
            .frame(width: 320, height: 400)
    }
}
