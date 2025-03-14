import Foundation
import SwiftUI

// MARK: - Line Number View
class LineNumberRulerView: NSRulerView {
    var textView: NSTextView
    let font: NSFont
    
    init(textView: NSTextView) {
        self.textView = textView
        self.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize + 1, weight: .regular)
        
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        
        self.clientView = textView
        self.ruleThickness = 40.0
        
        // Register for notifications to update when needed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSText.didChangeNotification,
            object: textView
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewBoundsDidChange),
            name: NSView.boundsDidChangeNotification,
            object: textView.enclosingScrollView?.contentView
        )
        
        // Add notification for cursor position changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSTextView.didChangeSelectionNotification,
            object: textView
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textDidChange(notification: Notification) {
        self.needsDisplay = true
    }
    
    @objc func viewBoundsDidChange(notification: Notification) {
        self.needsDisplay = true
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        // Set background color for the ruler
        NSColor(red: 0.95, green: 0.95, blue: 0.9, alpha: 1.0).setFill()
        rect.fill()
        
        // Draw a border on the right side
        NSColor.lightGray.setStroke()
        let borderPath = NSBezierPath()
        borderPath.move(to: NSPoint(x: rect.maxX - 0.5, y: rect.minY))
        borderPath.line(to: NSPoint(x: rect.maxX - 0.5, y: rect.maxY))
        borderPath.stroke()
        
        guard let textView = self.clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }
        
        let content = textView.string
        let visibleRect = textView.visibleRect
        
        // Get all line ranges
        let nsString = content as NSString
        var lineRanges = [NSRange]()
        var lineCount = 0
        
        // Handle empty document
        if content.isEmpty {
            drawLineNumber(1, at: visibleRect.minY, in: rect)
            return
        }
        
        // Count all lines including those with just a newline
        var index = 0
        while index < nsString.length {
            let lineRange = nsString.lineRange(for: NSRange(location: index, length: 0))
            lineRanges.append(lineRange)
            lineCount += 1
            index = NSMaxRange(lineRange)
        }
        
        // Add one more line if the document ends with a newline
        let endsWithNewline = content.hasSuffix("\n")
        if endsWithNewline {
            lineCount += 2
        }
        
        // Get the range of visible text
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let visibleRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        // Find the first visible line number
        var firstVisibleLine = 1
        index = 0
        while index < visibleRange.location && index < nsString.length {
            let lineRange = nsString.lineRange(for: NSRange(location: index, length: 0))
            firstVisibleLine += 1
            index = NSMaxRange(lineRange)
        }
        
        // Draw line numbers for visible lines
        for i in 0..<lineRanges.count {
            let lineRange = lineRanges[i]
            let lineNumber = i + 1
            
            // Check if this line is visible
            if NSLocationInRange(lineRange.location, visibleRange) ||
               (lineRange.location <= visibleRange.location &&
                NSMaxRange(lineRange) > visibleRange.location) {
                
                // Get the rect for this line
                let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
                var lineRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                
                // Ensure we have a reasonable height for empty lines
                if lineRect.height < 5 && lineRange.length <= 1 {
                    // Use the line height from font or a reasonable default
                    let defaultLineHeight = textView.font?.boundingRectForFont.height ?? 15.0
                    lineRect.size.height = defaultLineHeight
                }
                
                // Convert to ruler coordinates
                lineRect = textView.convert(lineRect, to: self)
                
                // Draw the line number
                drawLineNumber(lineNumber, at: lineRect.minY, in: rect)
            }
        }
        
        // Handle the case where content ends with a newline
        if endsWithNewline && !lineRanges.isEmpty {
            let lastLineRange = lineRanges.last!
            let lastLineGlyphRange = layoutManager.glyphRange(forCharacterRange: lastLineRange, actualCharacterRange: nil)
            var lastLineRect = layoutManager.boundingRect(forGlyphRange: lastLineGlyphRange, in: textContainer)
            
            // Get font line height for consistent spacing
            let fontLineHeight = textView.font?.boundingRectForFont.height ?? 15.0
            
            // Calculate position for the extra line
            var extraLineRect = lastLineRect
            
            // If last line has actual content, add full line height
            // Otherwise use a more precise calculation based on the cursor position
            if lastLineRect.height > fontLineHeight * 0.5 {
                extraLineRect.origin.y += lastLineRect.height
            } else {
                // For empty/small lines, position based on font metrics
                extraLineRect.origin.y += fontLineHeight
            }
            
            // Set a reasonable height for the extra line
            extraLineRect.size.height = fontLineHeight
            
            // Convert to ruler coordinates
            extraLineRect = textView.convert(extraLineRect, to: self)
            
            // Draw the line number for the extra line if it's visible
            if extraLineRect.intersects(rect) {
                drawLineNumber(lineCount, at: extraLineRect.minY, in: rect)
            }
        }
    }
    
    private func drawLineNumber(_ number: Int, at y: CGFloat, in rect: NSRect) {
        let numStr = "\(number)"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.gray
        ]
        
        let stringSize = numStr.size(withAttributes: attrs)
        let x = rect.width - stringSize.width - 4.0
        let yPos = y + 2  // Add a small offset for better alignment
        
        numStr.draw(at: NSPoint(x: x, y: yPos), withAttributes: attrs)
    }
}
