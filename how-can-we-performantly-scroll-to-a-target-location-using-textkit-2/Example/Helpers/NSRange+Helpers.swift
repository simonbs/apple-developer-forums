import AppKit

extension NSRange {
    init(_ range: NSTextRange, in textContentManager: NSTextContentManager) {
        let beginningOfDocument = textContentManager.documentRange.location
        let location = textContentManager.offset(from: beginningOfDocument, to: range.location)
        let length = textContentManager.offset(from: range.location, to: range.endLocation)
        self.init(location: location, length: length)
    }
}
