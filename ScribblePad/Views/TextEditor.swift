import Foundation
import SwiftUI

// MARK: - Custom TextEditor with Line Numbers
struct TextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont
    var isWordWrapEnabled: Bool
    
    func makeNSView(context: Context) -> NSScrollView {
        // Create a scroll view and text view
        let scrollView = NSTextView.scrollableTextView()
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Configure text view
        textView.delegate = context.coordinator
        textView.font = font
        textView.isRichText = false
        textView.allowsUndo = true
        textView.backgroundColor = NSColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1.0) // Ivory color
        textView.textColor = NSColor.black
        textView.insertionPointColor = NSColor.black
        textView.drawsBackground = true
        // Configure word wrap based on state
        configureWordWrap(textView: textView, scrollView: scrollView, enabled: isWordWrapEnabled)
        
        // Set text
        textView.string = text
        
        // Force layout to happen before adding the ruler
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        
        
        // Add line numbers
        let lineNumberView = LineNumberRulerView(textView: textView)
        scrollView.verticalRulerView = lineNumberView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        
        
        // Add border
        scrollView.borderType = .bezelBorder
        
        // Word wrap configuration is now handled via parameter updates
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else {
            return
        }
        
        // Only update if the text has changed from external sources
        if textView.string != text {
            textView.string = text
        }
        
        // Update word wrap configuration if needed
        configureWordWrap(textView: textView, scrollView: nsView, enabled: isWordWrapEnabled)
        
        // Make sure the ruler is visible and has correct thickness
        if !nsView.rulersVisible {
            nsView.rulersVisible = true
        }
        
        // Force ruler thickness to stay at 40.0 (safeguard against state restoration)
        if let rulerView = nsView.verticalRulerView {
            if rulerView.ruleThickness != 40.0 {
                rulerView.ruleThickness = 40.0
            }
        }
    }
    
    private func configureWordWrap(textView: NSTextView, scrollView: NSScrollView, enabled: Bool) {
        if enabled {
            // Enable word wrap
            textView.isHorizontallyResizable = false
            textView.isVerticallyResizable = true
            textView.autoresizingMask = [.width]
            textView.textContainer?.widthTracksTextView = true
            textView.textContainer?.containerSize = NSSize(
                width: scrollView.contentSize.width,
                height: CGFloat.greatestFiniteMagnitude
            )
            scrollView.hasHorizontalScroller = false
            scrollView.autohidesScrollers = true
        } else {
            // Disable word wrap - allow horizontal scrolling
            textView.isHorizontallyResizable = true
            textView.isVerticallyResizable = true
            textView.autoresizingMask = []
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
            scrollView.hasHorizontalScroller = true
            scrollView.hasVerticalScroller = true
            scrollView.autohidesScrollers = false
            
            // Configure text view for unlimited horizontal scrolling
            textView.minSize = NSSize(width: 0, height: 0)
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            
            // Force the text view to resize to accommodate all content
            textView.sizeToFit()
            
            // Ensure the text container has no width constraints
            textView.textContainer?.lineFragmentPadding = 0
        }
        
        // Force layout update and refresh scrollers
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        scrollView.tile()
        textView.needsDisplay = true
        scrollView.flashScrollers()
        
        // Refresh line numbers after word wrap change
        if let rulerView = scrollView.verticalRulerView {
            rulerView.needsDisplay = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditor
        
        init(_ parent: TextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
