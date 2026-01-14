import Foundation
import SwiftUI

// MARK: - Note Detail View
struct NoteDetailView: View {
    @ObservedObject var note: Note
    @State private var tempContent: String = ""
    
    var body: some View {
        TextEditor(
            text: $tempContent,
            font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize + 1, weight: .regular),
            isWordWrapEnabled: note.isWordWrapEnabled
        )
        .onAppear {
            // Set the content when the view appears
            tempContent = note.content ?? ""
        }
        .onChange(of: tempContent) { newValue in
            updateNote(content: newValue)
        }
    }
    
    private func updateNote(content: String) {
        note.content = content
        note.modificationDate = Date()
        PersistenceController.shared.saveContext()
    }
    
    // Helper method to find the first NSScrollView in the view hierarchy
    private func findFirstScrollView(in view: NSView?) -> NSScrollView? {
        guard let view = view else { return nil }
        
        if let scrollView = view as? NSScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            if let found = findFirstScrollView(in: subview) {
                return found
            }
        }
        
        return nil
    }
}
