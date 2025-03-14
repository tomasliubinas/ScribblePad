import SwiftUI
import CoreData
import AppKit

// MARK: - Main App
@main
struct ScriblePadApp: App {
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 700, minHeight: 500)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
                    if let window = notification.object as? NSWindow {
                        // Instead of allowing the window to close, hide it
                        window.resignKey()
                        window.orderOut(nil)
                        
                        // Prevent the app from terminating when the window is closed
                        NSApp.setActivationPolicy(.accessory)
                        
                        // Delay changing back to regular policy to avoid issues
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NSApp.setActivationPolicy(.regular)
                        }
                    }
                }
        }
        .commands {
            CommandMenu("Notes") {
                Button("New Note") {
                    NotificationCenter.default.post(name: .createNewNote, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
                
                Button("Delete Note") {
                    NotificationCenter.default.post(name: .deleteCurrentNote, object: nil)
                }
                .keyboardShortcut(.delete, modifiers: [.command])
            }
        }
    }
}

// MARK: - App Delegate for Menu Handling
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBarItem()
        
        // Set up to handle termination event
        NSApp.setActivationPolicy(.regular)
    }
    
    func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.title = "S"
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
    }
    
    @objc func statusBarButtonClicked() {
        if let window = NSApp.windows.first {
            if window.isVisible {
                // If window is already visible, just bring it to front
                NSApp.activate(ignoringOtherApps: true)
                window.makeKeyAndOrderFront(nil)
            } else {
                // If window is hidden, make it visible and bring to front
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                window.makeKeyAndOrderFront(nil)
            }
        } else {
            // If no window exists, make sure the app is active
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When clicking on the dock icon
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        if !flag {
            // If no visible windows, make the main window visible
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Prevent the app from terminating when the last window is closed
        return false
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let createNewNote = Notification.Name("createNewNote")
    static let deleteCurrentNote = Notification.Name("deleteCurrentNote")
}

// MARK: - Core Data Setup
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create a programmatic model description
        let noteEntity = NSEntityDescription()
        noteEntity.name = "Note"
        noteEntity.managedObjectClassName = NSStringFromClass(Note.self)
        
        // Create attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        
        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        contentAttribute.isOptional = true
        
        let creationDateAttribute = NSAttributeDescription()
        creationDateAttribute.name = "creationDate"
        creationDateAttribute.attributeType = .dateAttributeType
        
        let modificationDateAttribute = NSAttributeDescription()
        modificationDateAttribute.name = "modificationDate"
        modificationDateAttribute.attributeType = .dateAttributeType
        
        // Add attributes to entity
        noteEntity.properties = [idAttribute, contentAttribute, creationDateAttribute, modificationDateAttribute]
        
        // Create model with entity
        let model = NSManagedObjectModel()
        model.entities = [noteEntity]
        
        // Create container with model
        self.container = NSPersistentContainer(name: "ScriblePadModel", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func createNote() -> Note {
        let newNote = Note(context: container.viewContext)
        newNote.id = UUID()
        newNote.content = ""
        newNote.creationDate = Date()
        newNote.modificationDate = Date()
        saveContext()
        return newNote
    }
    
    func deleteNote(_ note: Note) {
        container.viewContext.delete(note)
        saveContext()
    }
}

// MARK: - Core Data Note Entity
class Note: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var content: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var modificationDate: Date?
    
    var noteTitle: String {
        let firstLine = content?.split(separator: "\n").first ?? ""
        return firstLine.isEmpty ? "New Note" : String(firstLine)
    }
}


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
