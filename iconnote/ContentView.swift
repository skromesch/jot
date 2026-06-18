import SwiftUI

struct ContentView: View {
    @State private var text = ""

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 15))
            .padding(16)
    }
}
