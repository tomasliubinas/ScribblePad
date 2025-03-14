import SwiftUI
import CoreData
import AppKit

// MARK: - Main App
@main
struct ScriblePadApp: App {
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(ScribleAppDelegate.self) var appDelegate
    
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
