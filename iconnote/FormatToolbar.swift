import AppKit
import SwiftUI

struct FormatToolbar: View {
    let textView: NSTextView?
    var onDelete: () -> Void = {}
    var onHelp: () -> Void = {}

    private var richTextView: RichNSTextView? { textView as? RichNSTextView }

    var body: some View {
        HStack(spacing: 4) {
            toolbarButton("bold", label: "B", font: .bold(.body)()) { richTextView?.toggleBold() }
            toolbarButton("italic", label: "I", font: .italic(.body)()) { richTextView?.toggleItalic() }
            toolbarButton("underline", label: "U") { richTextView?.toggleUnderline() }
            toolbarButton("strikethrough", sfSymbol: true) { richTextView?.toggleStrikethrough() }
            Divider().frame(height: 20)
            toolbarButton("list.bullet", sfSymbol: true) { richTextView?.applyList(kind: .disc) }
            toolbarButton("list.number", sfSymbol: true) { richTextView?.applyList(kind: .decimal) }
            toolbarButton("checklist", sfSymbol: true) { richTextView?.toggleCheckbox() }
            Divider().frame(height: 20)
            toolbarButton("textformat.size.smaller", sfSymbol: true) { richTextView?.adjustFontSize(delta: -2) }
            toolbarButton("textformat.size.larger", sfSymbol: true) { richTextView?.adjustFontSize(delta: 2) }
            Spacer()
            toolbarButton("trash", sfSymbol: true) { onDelete() }
            toolbarButton("questionmark.circle", sfSymbol: true) { onHelp() }
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
    }

    @ViewBuilder
    private func toolbarButton(
        _ id: String,
        label: String? = nil,
        sfSymbol: Bool = false,
        font: Font = .body,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if sfSymbol {
                    Image(systemName: id)
                } else if let label {
                    Text(label).font(font)
                }
            }
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.primary.opacity(0.06))
        .clipShape(.rect(cornerRadius: 5))
    }
}
