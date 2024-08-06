# How can we performantly scroll to a target location using TextKit 2?

Hi everyone,

I'm building a custom text editor using TextKit 2 and would like to scroll to a target location efficiently. For instance, I would like to move to the end of a document seamlessly, similar to how users can do in standard text editors by using CMD + Down.

**Background:**

NSTextView and TextEdit on macOS can navigate to the end of large documents in milliseconds. However, after reading the documentation and experimenting with various ideas using TextKit 2's APIs, it's not clear how third-party developers are supposed to achieve this.

**My Code:**

Here's the code I use to move the selection to the end of the document and scroll the viewport to reveal the selection.

```swift
override func moveToEndOfDocument(_ sender: Any?) {
    textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
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
}
```

While this code works as intended, it is very inefficient because `ensureLayout(_:)` is incredibly expensive and can take seconds for large documents.

**Issues Encountered:**

In my attempts, I have come across the following two issues.

- **Estimated Frames:** The frames of NSTextLayoutFragment and NSTextLineFragment are approximate and not precise enough for scrolling unless the text layout fragment has been fully laid out.
- **Laying out all text is expensive:** The frames become accurate once NSTextLayoutManager's `ensureLayout(for:)` method has been called with a range covering the entire document. However, `ensureLayout(for:)` is resource-intensive and can take seconds for large documents. NSTextView, on the other hand, accomplishes the same scrolling to the end of a document in milliseconds.

I've tried using NSTextViewportLayoutController's `relocateViewport(to:)` without success. It's unclear to me whether this function is intended for a use case like mine. If it is, I would appreciate some guidance on its proper usage.

**Configuration:**

I'm testing on macOS Sonoma 14.5 (23F79), Swift (AppKit), Xcode 15.4 (15F31d).

I'm working on a multi-platform project written in AppKit and UIKit, so I'm looking for either a single solution that works in both AppKit and UIKit or two solutions, one for each UI framework.

**Question:**

How can third-party developers scroll to a target location, specifically the end of a document, performantly using TextKit 2?

**Steps to Reproduce:**

The issue can be reproduced using [the example project](https://github.com/simonbs/apple-developer-forums/tree/main/how-can-we-performantly-scroll-to-a-target-location-using-textkit-2) (download from link below) by following these steps:

1. Open the example project.
2. Run the example app on a Mac. The example app shows an uneditable text view in a scroll view. The text view displays a long text.
3. Press the "Move to End of Document" toolbar item.
4. Notice that the text view has scrolled to the bottom, but this took several seconds (~3 seconds on my MacBook Pro 16-inch, 2021). The duration will be shown in Xcode's log.

You can open the ExampleTextView.swift file and find the implementation of `moveToEndOfDocument(_:).` Comment out line 84 where the `ensureLayout(_:)` is called, rerun the app, and then select "Move to End of Document" again. This time, you will notice that the text view moves fast but does not end up at the bottom of the document.

You may also open the large-file.json in the project, the same file that the example app displays, in TextEdit, and press CMD+Down to move to the end of the document. Notice that TextEdit does this in mere milliseconds.

**Example Project:**

The example project is located on GitHub:

[https://github.com/simonbs/apple-developer-forums/tree/main/how-can-we-performantly-scroll-to-a-target-location-using-textkit-2](https://github.com/simonbs/apple-developer-forums/tree/main/how-can-we-performantly-scroll-to-a-target-location-using-textkit-2)

Any advice or guidance on how to achieve this with TextKit 2 would be greatly appreciated.

Thanks in advance!

Best regards,

Simon
