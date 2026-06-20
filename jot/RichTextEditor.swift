import AppKit
import Carbon.HIToolbox
import SwiftUI

// MARK: - NSTextView subclass

class RichNSTextView: NSTextView {

    // MARK: - Event handling

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let charIndex = characterIndex(at: point),
           let storage = textStorage,
           charIndex < storage.length {
            let char = (storage.string as NSString).character(at: charIndex)
            if char == 0x2610 || char == 0x2611 {
                let toggled: String = char == 0x2610 ? "☑" : "☐"
                storage.beginEditing()
                storage.replaceCharacters(in: NSRange(location: charIndex, length: 1), with: toggled)
                storage.endEditing()
                didChangeText()
                return
            }
        }
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // All shortcuts use keyCode (physical key position) — layout independent
        if mods == .command {
            switch event.keyCode {
            case UInt16(kVK_ANSI_B): toggleBold(); return
            case UInt16(kVK_ANSI_I): toggleItalic(); return
            case UInt16(kVK_ANSI_U): toggleUnderline(); return
            default: break
            }
        }

        if mods == [.command, .shift] {
            switch event.keyCode {
            case UInt16(kVK_ANSI_X): toggleStrikethrough(); return     // ⌘⇧X
            case UInt16(kVK_ANSI_L): applyList(kind: .disc); return    // ⌘⇧L — bullet
            case UInt16(kVK_ANSI_O): applyList(kind: .decimal); return // ⌘⇧O — numbered
            case UInt16(kVK_ANSI_K): toggleCheckbox(); return          // ⌘⇧K — checkbox
            default: break
            }
        }

        super.keyDown(with: event)
    }

    // MARK: - Formatting

    func toggleBold() { toggleFontTrait(.boldFontMask) }
    func toggleItalic() { toggleFontTrait(.italicFontMask) }

    func toggleUnderline() {
        guard let storage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }
        var allUnderlined = true
        storage.enumerateAttribute(.underlineStyle, in: range, options: []) { value, _, _ in
            if (value as? Int) ?? 0 == 0 { allUnderlined = false }
        }
        let newValue = allUnderlined ? 0 : NSUnderlineStyle.single.rawValue
        storage.beginEditing()
        storage.addAttribute(.underlineStyle, value: newValue, range: range)
        storage.endEditing()
        didChangeText()
    }

    func toggleStrikethrough() {
        guard let storage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }
        var allStruck = true
        storage.enumerateAttribute(.strikethroughStyle, in: range, options: []) { value, _, _ in
            if (value as? Int) ?? 0 == 0 { allStruck = false }
        }
        let newValue = allStruck ? 0 : NSUnderlineStyle.single.rawValue
        storage.beginEditing()
        storage.addAttribute(.strikethroughStyle, value: newValue, range: range)
        storage.endEditing()
        didChangeText()
    }

    func applyList(kind: NSTextList.MarkerFormat) {
        guard let storage = textStorage else { return }
        let range = selectedRange()
        let str = storage.string as NSString
        let paraRange = str.paragraphRange(for: range)
        let lines = str.substring(with: paraRange).components(separatedBy: "\n")

        let bulletPrefix = "• "

        func isNumberedLine(_ s: String) -> Bool {
            guard !s.isEmpty, let dot = s.firstIndex(of: ".") else { return false }
            guard Int(s[s.startIndex..<dot]) != nil else { return false }
            let afterDot = s.index(after: dot)
            return afterDot < s.endIndex && s[afterDot] == " "
        }

        func stripListPrefix(_ s: String) -> String {
            if s.hasPrefix(bulletPrefix) { return String(s.dropFirst(bulletPrefix.count)) }
            if isNumberedLine(s), let dot = s.firstIndex(of: ".") {
                let after = s.index(dot, offsetBy: 2)
                return after <= s.endIndex ? String(s[after...]) : s
            }
            return s
        }

        let nonEmpty = lines.filter { !$0.isEmpty }
        let allFormatted = !nonEmpty.isEmpty && nonEmpty.allSatisfy { line in
            kind == .disc ? line.hasPrefix(bulletPrefix) : isNumberedLine(line)
        }

        var result = ""
        var num = 1
        for (i, line) in lines.enumerated() {
            let isLast = i == lines.count - 1
            if isLast && line.isEmpty { break }

            if line.isEmpty {
                result += ""
            } else if allFormatted {
                result += stripListPrefix(line)
            } else {
                let base = stripListPrefix(line)
                result += kind == .disc ? bulletPrefix + base : "\(num). " + base
                num += 1
            }
            if !isLast { result += "\n" }
        }

        storage.beginEditing()
        storage.replaceCharacters(in: paraRange, with: result)
        storage.endEditing()
        didChangeText()
    }

    func toggleCheckbox() {
        guard let storage = textStorage else { return }
        let range = selectedRange()
        let str = storage.string as NSString
        let paraRange = str.paragraphRange(for: range)
        let lines = str.substring(with: paraRange).components(separatedBy: "\n")
        var result = ""
        for line in lines {
            if line.hasPrefix("☑ ") {
                result += "☐ " + line.dropFirst(2) + "\n"
            } else if line.hasPrefix("☐ ") {
                result += "☑ " + line.dropFirst(2) + "\n"
            } else {
                result += "☐ " + line + "\n"
            }
        }
        if result.hasSuffix("\n") { result = String(result.dropLast()) }
        storage.beginEditing()
        storage.replaceCharacters(in: paraRange, with: result)
        storage.endEditing()
        didChangeText()
    }

    func adjustFontSize(delta: CGFloat) {
        guard let storage = textStorage else { return }
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: fullRange, options: []) { value, subRange, _ in
            let current = (value as? NSFont) ?? NSFont.systemFont(ofSize: 15)
            let newSize = max(8, min(72, current.pointSize + delta))
            storage.addAttribute(.font, value: NSFontManager.shared.convert(current, toSize: newSize), range: subRange)
        }
        storage.endEditing()
        let defaultFont = self.font ?? NSFont.systemFont(ofSize: 15)
        self.font = NSFontManager.shared.convert(defaultFont, toSize: max(8, min(72, defaultFont.pointSize + delta)))
        didChangeText()
    }

    // MARK: - Private helpers

    private func toggleFontTrait(_ trait: NSFontTraitMask) {
        guard let storage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }
        var allHaveTrait = true
        storage.enumerateAttribute(.font, in: range, options: []) { value, _, _ in
            let font = (value as? NSFont) ?? NSFont.systemFont(ofSize: 15)
            if !NSFontManager.shared.traits(of: font).contains(trait) { allHaveTrait = false }
        }
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let current = (value as? NSFont) ?? NSFont.systemFont(ofSize: 15)
            let result: NSFont = allHaveTrait
                ? NSFontManager.shared.convert(current, toNotHaveTrait: trait)
                : NSFontManager.shared.convert(current, toHaveTrait: trait)
            storage.addAttribute(.font, value: result, range: subRange)
        }
        storage.endEditing()
        didChangeText()
    }

    private func characterIndex(at point: NSPoint) -> Int? {
        guard let lm = layoutManager, let tc = textContainer else { return nil }
        var fraction: CGFloat = 0
        let glyphIdx = lm.glyphIndex(for: point, in: tc, fractionOfDistanceThroughGlyph: &fraction)
        guard fraction < 1.0 else { return nil }
        let charRange = lm.characterRange(forGlyphRange: NSRange(location: glyphIdx, length: 1), actualGlyphRange: nil)
        return charRange.location
    }
}

// MARK: - NSViewRepresentable wrapper

struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var resetGeneration: Int
    var onTextViewReady: (NSTextView) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        let textView = RichNSTextView(frame: .zero)
        textView.minSize = .zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = .width
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        textView.isRichText = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.delegate = context.coordinator

        textView.textStorage?.setAttributedString(attributedText)
        scrollView.documentView = textView

        DispatchQueue.main.async {
            onTextViewReady(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if context.coordinator.isEditing { return }
        if context.coordinator.lastResetGeneration != resetGeneration {
            context.coordinator.lastResetGeneration = resetGeneration
            textView.textStorage?.setAttributedString(attributedText)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var isEditing = false
        var lastResetGeneration = 0

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            isEditing = true
            defer { isEditing = false }
            parent.attributedText = textView.attributedString()
        }
    }
}
