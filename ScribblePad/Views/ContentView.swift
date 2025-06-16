import Foundation
import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.creationDate, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<Note>
    @State private var selectedNoteID: UUID?
    @State private var selectedNote: Note?
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                // Sidebar
                VStack {
                HStack {
                    Text("Notes")
                        .font(.headline)
                    Spacer()
                    Button(action: addNote) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    if selectedNote != nil {
                        Button(action: {
                            if let note = selectedNote {
                                deleteNote(note)
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding([.horizontal, .top])
                
                List {
                    ForEach(notes, id: \.id) { note in
                        HStack {
                            Text(note.noteTitle)
                                .lineLimit(1)
                            Spacer()
                            if let date = note.modificationDate {
                                Text(dateFormatter.string(from: date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .background(selectedNoteID == note.id ? Color.accentColor.opacity(0.2) : Color.clear)
                        .onTapGesture {
                            // Explicitly manage selection state
                            selectedNoteID = note.id
                            selectedNote = note
                        }
                    }
                    .onDelete(perform: deleteNotes)
                }
            }
            .frame(minWidth: 200)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
            
            // Detail View
            if let note = selectedNote {
                NoteDetailView(note: note)
                    .id(note.id) // Force view to recreate when note changes
                    .navigationTitle(note.noteTitle)
            } else {
                Text("No Note Selected")
                    .font(.title)
                    .foregroundColor(.gray)
                    .navigationTitle("ScriblePad")
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onAppear {
            checkAndCreateInitialNoteIfNeeded()
            setupSidebarToggleKeyboardShortcut()
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewNote)) { _ in
            addNote()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteCurrentNote)) { _ in
            if let note = selectedNote {
                deleteNote(note)
            }
        }
        
        // Status Bar
        StatusBarView(
            documentCreationDate: selectedNote?.creationDate,
            documentModificationDate: selectedNote?.modificationDate,
            documentContent: selectedNote?.content,
            isWordWrapEnabled: selectedNote?.isWordWrapEnabled ?? true,
            onWordWrapToggle: {
                if let note = selectedNote {
                    note.isWordWrapEnabled.toggle()
                    note.modificationDate = Date()
                    PersistenceController.shared.saveContext()
                }
            }
        )
    }
    }
    
    private func setupSidebarToggleKeyboardShortcut() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.keyCode == 0x21 { // Command + [
                toggleSidebar()
                return nil
            }
            return event
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    private func checkAndCreateInitialNoteIfNeeded() {
        if notes.isEmpty {
            let newNote = PersistenceController.shared.createNote()
            selectedNoteID = newNote.id
            selectedNote = newNote
        } else if selectedNote == nil {
            selectedNoteID = notes.first?.id
            selectedNote = notes.first
        }
    }
    
    private func addNote() {
        let newNote = PersistenceController.shared.createNote()
        selectedNoteID = newNote.id
        selectedNote = newNote
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func deleteNote(_ note: Note) {
        // Set a new selection before deleting
        if note.id == selectedNoteID {
            if let currentIndex = notes.firstIndex(where: { $0.id == note.id }) {
                if notes.count > 1 {
                    if currentIndex < notes.count - 1 {
                        selectedNoteID = notes[currentIndex + 1].id
                        selectedNote = notes[currentIndex + 1]
                    } else {
                        selectedNoteID = notes[currentIndex - 1].id
                        selectedNote = notes[currentIndex - 1]
                    }
                } else {
                    selectedNoteID = nil
                    selectedNote = nil
                }
            }
        }
        
        PersistenceController.shared.deleteNote(note)
    }
    
    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            deleteNote(note)
        }
    }
}


// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data
        let note1 = Note(context: viewContext)
        note1.id = UUID()
        note1.content = "First sample note\nThis is some sample content."
        note1.creationDate = Date()
        note1.modificationDate = Date()
        
        let note2 = Note(context: viewContext)
        note2.id = UUID()
        note2.content = "Shopping list\n- Milk\n- Eggs\n- Bread"
        note2.creationDate = Date().addingTimeInterval(-3600)
        note2.modificationDate = Date()
        
        try? viewContext.save()
        
        return ContentView()
            .environment(\.managedObjectContext, viewContext)
    }
}
