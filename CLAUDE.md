# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScribblePad is a native macOS note-taking application built with SwiftUI and Core Data. It features a dual-pane interface with a sidebar for note navigation and a main editor area with line numbers and syntax highlighting.

## Build Commands

```bash
# Build the project
xcodebuild -project ScribblePad.xcodeproj -scheme ScribblePad -configuration Debug build

# Run tests
xcodebuild -project ScribblePad.xcodeproj -scheme ScribblePad -configuration Debug test

# Run unit tests in Xcode: ⌘+U
# Build and run in Xcode: ⌘+R
```

## Architecture

### Core Data Model
- **PersistenceController**: Singleton managing Core Data stack with programmatic model definition
- **Note Entity**: UUID-based notes with content, creation/modification dates
- Model is created programmatically (no .xcdatamodeld file)

### App Structure
- **ScribblePadApp**: Main app entry point with window tabbing configuration
- **ContentView**: Master-detail view with sidebar navigation and note list
- **NoteDetailView**: Custom text editor with real-time content saving
- **TextEditor**: Custom text editor with line numbers and monospace font

### Key Components
- **LineNumberRulerView**: Custom NSScrollView subclass for line number display
- **StatusBarView**: Bottom status bar showing document stats and modification dates
- **Custom Menu Commands**: Keyboard shortcuts for note creation (⌘+N) and deletion (⌘+Delete)

### Data Flow
- Notes are auto-saved on content changes via @onChange
- Selection state managed through selectedNoteID and selectedNote state variables
- NotificationCenter used for menu command communication

### UI Features
- Automatic window tabbing enabled
- Sidebar toggle with keyboard shortcut (⌘+[)
- Custom keyboard shortcuts for note management
- Responsive dual-column navigation view

## Project File Structure

```
ScribblePad/
├── Controllers/           # Core Data management
├── Entities/             # Core Data model classes
├── Views/               # SwiftUI views and components
├── Assets.xcassets/     # App icons and colors
└── ScribblePad.entitlements  # App permissions
```

## Development Notes

- The app uses programmatic Core Data model creation instead of .xcdatamodeld
- Window tabbing is configured at app launch and per-window basis
- Text editing uses custom TextEditor with monospace font and real-time saving
- The project name has inconsistent spelling (ScriblePad vs ScribblePad) in some file paths