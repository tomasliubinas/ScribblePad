import Foundation
import SwiftUI
import CodeEditSourceEditor
import CodeEditLanguages

// MARK: - Note Detail View
struct NoteDetailView: View {
    @ObservedObject var note: Note
    @State private var tempContent: String
    @State private var editorState = SourceEditorState()

    // Available themes: .light, .dark, .ivory
    private let editorTheme: EditorTheme = .ivory

    init(note: Note) {
        self.note = note
        // Initialize tempContent with the note's content
        _tempContent = State(initialValue: note.content ?? "")
    }

    private var editorConfiguration: SourceEditorConfiguration {
        SourceEditorConfiguration(
            appearance: .init(
                theme: editorTheme,
                useThemeBackground: false, // Use window background for gutter (different from editor)
                font: .monospacedSystemFont(ofSize: NSFont.systemFontSize + 1, weight: .regular),
                lineHeightMultiple: 1.2,
                wrapLines: note.isWordWrapEnabled,
                tabWidth: 4
            ),
            peripherals: .init(
                showMinimap: true
            )
        )
    }

    var body: some View {
        SourceEditor(
            $tempContent,
            language: .markdown, // Enable Markdown syntax highlighting
            configuration: editorConfiguration,
            state: $editorState
        )
        .id(note.isWordWrapEnabled) // Force view recreation when word wrap changes
        .onChange(of: tempContent) { newValue in
            updateNote(content: newValue)
        }
    }

    private func updateNote(content: String) {
        note.content = content
        note.modificationDate = Date()
        PersistenceController.shared.saveContext()
    }
}
