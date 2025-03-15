import Foundation
import SwiftUI

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
