import SwiftUI

struct StatusBarView: View {
    let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    
    var documentCreationDate: Date?
    var documentModificationDate: Date?
    var documentContent: String?
    var isWordWrapEnabled: Bool
    var onWordWrapToggle: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var textStats: (words: Int, chars: Int) {
        guard let content = documentContent else { return (0, 0) }
        let chars = content.count
        let words = content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        return (words, chars)
    }
    
    var body: some View {
        HStack {
            // Left side: App info
            HStack(spacing: 8) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text("ScribblePad")
                    .bold()
                
                Text("v\(buildVersion) (build: \(buildNumber))")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Right side: Document info and stats
            HStack(spacing: 16) {
                // Text statistics
                if let _ = documentContent {
                    Text("\(textStats.words) words")
                        .foregroundColor(.secondary)
                    Text("\(textStats.chars) characters")
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .frame(height: 12)
                }
                
                // Word wrap toggle
                HStack(spacing: 4) {
                    Text("Word wrap:")
                        .foregroundColor(.secondary)
                    Toggle("", isOn: Binding(
                        get: { isWordWrapEnabled },
                        set: { _ in onWordWrapToggle() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .scaleEffect(0.8)
                }
                
                Divider()
                    .frame(height: 12)
                
                // Document dates
                if let created = documentCreationDate {
                    HStack(spacing: 4) {
                        Text("Created:")
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: created))
                            .foregroundColor(.secondary)
                    }
                }
                
                
                if let modified = documentModificationDate {
                    HStack(spacing: 4) {
                        Text("Modified:")
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: modified))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(NSColor.windowBackgroundColor))
        .border(Color(NSColor.separatorColor), width: 1)
    }
}
/*
#Preview {
    StatusBarView(
        documentCreationDate: Date(),
        documentModificationDate: Date()
    )
    .frame(width: 600)
 
}*/
