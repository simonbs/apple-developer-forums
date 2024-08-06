import Cocoa

final class ViewController: NSViewController {
    var textView: ExampleTextView {
        scrollView.documentView! as! ExampleTextView
    }
    
    private let scrollView: NSScrollView = {
        let this = ExampleTextView.scrollableTextView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.hasVerticalScroller = true
        return this
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = Bundle.main.url(forResource: "large-file", withExtension: "json")!
        textView.loadText(at: fileURL)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
