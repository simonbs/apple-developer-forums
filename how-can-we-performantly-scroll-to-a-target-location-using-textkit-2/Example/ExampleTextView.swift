import AppKit

// Displays a text using TextKit 2. Does not implement editing interactions
// as they are not needed for the purpose of this example.
final class ExampleTextView: NSView {
    override var isFlipped: Bool {
        true
    }

    private let textContainer = NSTextContainer()
    private let textLayoutManager = NSTextLayoutManager()
    private let textContentStorage = TextContentStorage()

    override required init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textLayoutManager.delegate = self
        textLayoutManager.textContainer = textContainer
        textLayoutManager.textViewportLayoutController.delegate = self
        textContentStorage.addTextLayoutManager(textLayoutManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func scrollableTextView() -> NSScrollView {
        let textView = Self(frame: .zero)
        textView.autoresizingMask = [.width, .height]
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        return scrollView
    }

    override func prepareContent(in rect: NSRect) {
        let heightExpansion = rect.height
        var expandedRect = rect
        expandedRect.origin.y -= heightExpansion / 2
        expandedRect.size.height += heightExpansion
        super.prepareContent(in: expandedRect)
        wantsLayer = true
        layoutSubtreeIfNeeded()
    }

    override func layout() {
        super.layout()
        let sizingView = enclosingScrollView?.contentView ?? self
        textContainer.size = CGSize(width: sizingView.frame.width, height: 0)
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    // Loads text at the specified file URL. Ensures TextKit has some sample text to work with.
    func loadText(at fileURL: URL) {
        let text = try! String(contentsOf: fileURL)
        let attributedString = NSAttributedString(string: text)
        let textParagraph = NSTextParagraph(attributedString: attributedString)
        textContentStorage.performEditingTransaction {
            textContentStorage.replaceContents(in: textContentStorage.documentRange, with: [textParagraph])
        }
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    // 👀 👀 👀 👀 👀 👀 👀 LOOK HERE 👀 👀 👀 👀 👀 👀 👀
    //
    // When implementing a custom text editor using AppKit's NSTextInput,
    // developers must provide an implementation of moveToEndOfDocument().
    //
    // NSTextView, and as such TextEdit on macOS, manages to move to the end of
    // a large document performantly. However, I struggle to come up with a
    // performant implementation using TextKit 2.
    //
    // ❓ I'm hoping Apple Developer Technical Support can tell me how NSTextView
    // and TextEdit manages to scroll to the end of a document performantly.
    override func moveToEndOfDocument(_ sender: Any?) {
        // 👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇
        // If we do not call ensureLayout(for:) to layout the entire document, then we'll
        // get incorrect frames for the NSTextLayoutFragment and NSTextLineFragment.
        // However, ensureLayout(for:) is very expensive, so how does NSTextView manage to
        // jump to the end of a large document performantly?
        let measureStartDate = Date()
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        print("⏰ ensureLayout(for:) took \(Date().timeIntervalSince(measureStartDate))s")
        // 👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆

        let targetLocation = textLayoutManager.documentRange.endLocation
        let beforeTargetLocation = textLayoutManager.location(targetLocation, offsetBy: -1)!
        textLayoutManager.textViewportLayoutController.layoutViewport()
        guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: beforeTargetLocation) else {
            return
        }
        guard let textLineFragment = textLayoutFragment.textLineFragment(for: targetLocation, isUpstreamAffinity: true) else {
            return
        }
        let lineFrame = textLayoutFragment.layoutFragmentFrame
        let lineFragmentFrame = textLineFragment.typographicBounds.offsetBy(dx: 0, dy: lineFrame.minY)
        scrollToVisible(lineFragmentFrame)
        print("👉 RESULT: Last line fragment of the document is at \(lineFragmentFrame)")
    }
}

extension ExampleTextView: NSTextLayoutManagerDelegate {
    func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        textLayoutFragmentFor location: any NSTextLocation,
        in textElement: NSTextElement
    ) -> NSTextLayoutFragment {
        NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}

extension ExampleTextView: NSTextViewportLayoutControllerDelegate {
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        let visibleRect = enclosingScrollView?.documentVisibleRect ?? visibleRect
        let minX = min(preparedContentRect.minX, visibleRect.minX)
        let minY = min(preparedContentRect.minY, visibleRect.minY)
        let maxX = max(preparedContentRect.maxX, visibleRect.maxX)
        let maxY = max(preparedContentRect.maxY, visibleRect.maxY)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func textViewportLayoutControllerWillLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
    }

    func textViewportLayoutControllerDidLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        let size = textLayoutManager.usageBoundsForTextContainer.size
        setFrameSize(size)
    }

    func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {
        let textLayoutFragmentLayer = TextLayoutFragmentLayer(textLayoutFragment: textLayoutFragment)
        textLayoutFragmentLayer.frame = textLayoutFragment.layoutFragmentFrame
        layer?.addSublayer(textLayoutFragmentLayer)
        textLayoutFragmentLayer.displayIfNeeded()
    }
}
