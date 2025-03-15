import SwiftUI
import CoreData
import AppKit

// MARK: - Main App
@main
struct ScriblePadApp: App {
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(ScribleAppDelegate.self) var appDelegate
    
    init() {
        // Set app to always prefer tabs
        NSWindow.allowsAutomaticWindowTabbing = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 700, minHeight: 500)
                .onAppear {
                    // Ensure windows have tabbing enabled
                    DispatchQueue.main.async {
                        for window in NSApp.windows {
                            window.tabbingMode = .preferred
                        }
                    }
                }
        }
        .commands {
            // Just change the New Window shortcut
            CommandGroup(replacing: .newItem) {
                Button("New Window") {
                    // This will use the default WindowGroup behavior to create a new window,
                    // which will become a tab due to system settings
                    NSApplication.shared.sendAction(#selector(NSResponder.newWindowForTab(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            
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
