import Foundation
import SwiftUI

// MARK: - Custom TextEditor with Line Numbers
struct TextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont
    
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
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
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
