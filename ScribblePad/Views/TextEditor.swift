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
        
        // Debug: Check UserDefaults for ruler-related keys
        let userDefaults = UserDefaults.standard
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let rulerKeys = allKeys.filter { $0.contains("Ruler") || $0.contains("ruler") || $0.contains("NSRuler") }
        if !rulerKeys.isEmpty {
            print("🔍 DEBUG: Found ruler-related UserDefaults keys: \(rulerKeys)")
            for key in rulerKeys {
                print("🔍 DEBUG: \(key) = \(userDefaults.object(forKey: key) ?? "nil")")
            }
        } else {
            print("🔍 DEBUG: No ruler-related UserDefaults keys found")
        }
        
        // Add line numbers
        let lineNumberView = LineNumberRulerView(textView: textView)
        scrollView.verticalRulerView = lineNumberView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        
        // Debug: Log final scroll view ruler state
        print("🔍 DEBUG: Final scroll view ruler thickness: \(scrollView.verticalRulerView?.ruleThickness ?? 0)")
        print("🔍 DEBUG: Final scroll view rulers visible: \(scrollView.rulersVisible)")
        
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
                print("🔍 DEBUG: Correcting ruler thickness from \(rulerView.ruleThickness) to 40.0")
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
            // Don't set container width explicitly - let widthTracksTextView handle it
            // This ensures the text view frame (which accounts for the ruler) is used
            textView.textContainer?.containerSize = NSSize(
                width: textView.frame.width,
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
