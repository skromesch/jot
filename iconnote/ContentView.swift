import AppKit
import SwiftUI

struct ContentView: View {
    @State private var attributedText = NSAttributedString()
    @State private var textView: NSTextView?
    @State private var showHelp = false
    @State private var showDeleteConfirm = false
    @State private var resetGeneration = 0

    var body: some View {
        Group {
            if showHelp {
                HelpView(onClose: { showHelp = false })
            } else {
                VStack(spacing: 0) {
                    RichTextEditor(attributedText: $attributedText, resetGeneration: resetGeneration) { tv in
                        textView = tv
                    }
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 4, trailing: 12))

                    Divider()

                    FormatToolbar(
                        textView: textView,
                        onDelete: { showDeleteConfirm = true },
                        onHelp: { showHelp = true }
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: showHelp)
        .alert("Clear all text?", isPresented: $showDeleteConfirm) {
            Button("Clear", role: .destructive) {
                attributedText = NSAttributedString()
                resetGeneration += 1
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all content in the editor.")
        }
    }
}
