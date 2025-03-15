import Foundation
import SwiftUI

// MARK: - Notification Names
extension Notification.Name {
    static let createNewNote = Notification.Name("createNewNote")
    static let deleteCurrentNote = Notification.Name("deleteCurrentNote")
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
