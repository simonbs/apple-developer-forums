import AppKit

final class WindowController: NSWindowController {
    private var textView: ExampleTextView {
        (contentViewController as? ViewController)!.textView
    }

    @IBAction override func moveToEndOfDocument(_ sender: Any?) {
        textView.moveToEndOfDocument(sender)
    }
}
