import SwiftUI

struct HelpView: View {
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Jot Help")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    group(title: "Text Formatting") {
                        shortcut("Bold", key: "⌘B")
                        shortcut("Italic", key: "⌘I")
                        shortcut("Underline", key: "⌘U")
                        shortcut("Strikethrough", key: "⌘⇧X")
                    }

                    Text("Select text first, then apply formatting.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    group(title: "Lists") {
                        shortcut("Bullet list", key: "⌘⇧L")
                        shortcut("Numbered list", key: "⌘⇧O")
                        shortcut("Checkbox", key: "⌘⇧K")
                        Text("Click ☐ / ☑ in the text to toggle a checkbox.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    group(title: "Font Size (toolbar buttons only)") {
                        row(icon: "textformat.size.larger", label: "Increase font size (+2 pt)")
                        row(icon: "textformat.size.smaller", label: "Decrease font size (−2 pt)")
                        Text("Applies to all text. Range: 8–72 pt.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    group(title: "General") {
                        shortcut("Quit", key: "⌘Q")
                        Text("Note: Text is not saved when the app quits.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
        }
    }

    @ViewBuilder
    private func group<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func shortcut(_ label: String, key: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(key)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .font(.body)
    }

    private func row(icon: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            Text(label)
        }
        .font(.body)
    }
}
