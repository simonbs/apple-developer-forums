import AppKit

final class TextContentStorage: NSTextContentStorage {
    override func replaceContents(in range: NSTextRange, with textElements: [NSTextElement]?) {
        assert(hasEditingTransaction, "No editing transaction was started. Wrap the call in performEditingTransaction(_:)")
        guard let textStorage else {
            return
        }
        guard let textParagraphs = textElements?.compactMap({ $0 as? NSTextParagraph }) else {
            return
        }
        let replacementString = NSMutableAttributedString()
        replacementString.beginEditing()
        for textParagraph in textParagraphs {
            replacementString.append(textParagraph.attributedString)
        }
        replacementString.endEditing()
        let nsRange = NSRange(range, in: self)
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: nsRange, with: replacementString)
        textStorage.endEditing()
    }
}
