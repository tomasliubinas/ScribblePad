//
//  LineNumberTextEditor.swift
//  ScriblePad
//
//  Created by Tomas Liubinas Paysera on 2025-03-14.
//

import Foundation
import SwiftUI



// MARK: - Custom TextEditor with Line Numbers
struct LineNumberTextEditor: NSViewRepresentable {
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
        
        // Add line numbers
        let lineNumberView = LineNumberRulerView(textView: textView)
        scrollView.verticalRulerView = lineNumberView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        
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
        
        // Make sure the ruler is visible
        if !nsView.rulersVisible {
            nsView.rulersVisible = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: LineNumberTextEditor
        
        init(_ parent: LineNumberTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
