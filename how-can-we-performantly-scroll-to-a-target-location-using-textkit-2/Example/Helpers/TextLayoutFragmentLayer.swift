import AppKit

final class TextLayoutFragmentLayer: CALayer {
    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                setNeedsDisplay()
            }
        }
    }

    private let textLayoutFragment: NSTextLayoutFragment

    init(textLayoutFragment: NSTextLayoutFragment) {
        self.textLayoutFragment = textLayoutFragment
        super.init()
        commonInitialization()
    }

    override init(layer: Any) {
        guard let layer = layer as? Self else {
            fatalError("Expected instance of type \(Self.self) but got \(type(of: layer))")
        }
        self.textLayoutFragment = layer.textLayoutFragment
        super.init(layer: layer)
        commonInitialization()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInitialization() {
        contentsScale = NSScreen.main?.backingScaleFactor ?? 1
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        textLayoutFragment.draw(at: .zero, in: ctx)
    }
}
