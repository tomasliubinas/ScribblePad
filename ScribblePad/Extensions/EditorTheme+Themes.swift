//
//  EditorTheme+Themes.swift
//  ScribblePad
//

import Foundation
import AppKit
import CodeEditSourceEditor

extension EditorTheme {
    /// Light theme - Xcode-like light color scheme
    static var light: EditorTheme {
        EditorTheme(
            text: Attribute(color: NSColor(hex: "000000")),
            insertionPoint: NSColor(hex: "000000"),
            invisibles: Attribute(color: NSColor(hex: "D6D6D6")),
            background: NSColor(hex: "FFFFFF"),
            lineHighlight: NSColor(hex: "ECF5FF"),
            selection: NSColor(hex: "B2D7FF"),
            keywords: Attribute(color: NSColor(hex: "9B2393"), bold: true),
            commands: Attribute(color: NSColor(hex: "326D74")),
            types: Attribute(color: NSColor(hex: "0B4F79")),
            attributes: Attribute(color: NSColor(hex: "815F03")),
            variables: Attribute(color: NSColor(hex: "0F68A0")),
            values: Attribute(color: NSColor(hex: "6C36A9")),
            numbers: Attribute(color: NSColor(hex: "1C00CF")),
            strings: Attribute(color: NSColor(hex: "C41A16")),
            characters: Attribute(color: NSColor(hex: "1C00CF")),
            comments: Attribute(color: NSColor(hex: "267507"))
        )
    }

    /// Dark theme - Xcode-like dark color scheme
    static var dark: EditorTheme {
        EditorTheme(
            text: Attribute(color: NSColor(hex: "FFFFFF")),
            insertionPoint: NSColor(hex: "007AFF"),
            invisibles: Attribute(color: NSColor(hex: "53606E")),
            background: NSColor(hex: "292A30"),
            lineHighlight: NSColor(hex: "2F3239"),
            selection: NSColor(hex: "646F83"),
            keywords: Attribute(color: NSColor(hex: "FF7AB2"), bold: true),
            commands: Attribute(color: NSColor(hex: "78C2B3")),
            types: Attribute(color: NSColor(hex: "6BDFFF")),
            attributes: Attribute(color: NSColor(hex: "CC9768")),
            variables: Attribute(color: NSColor(hex: "4EB0CC")),
            values: Attribute(color: NSColor(hex: "B281EB")),
            numbers: Attribute(color: NSColor(hex: "D9C97C")),
            strings: Attribute(color: NSColor(hex: "FF8170")),
            characters: Attribute(color: NSColor(hex: "D9C97C")),
            comments: Attribute(color: NSColor(hex: "7F8C98"))
        )
    }

    /// Ivory theme - warm paper-like background
    static var ivory: EditorTheme {
        EditorTheme(
            text: Attribute(color: .textColor),
            insertionPoint: .textColor,
            invisibles: Attribute(color: .tertiaryLabelColor),
            background: NSColor(hex: "FAF8F0"),
            lineHighlight: NSColor(hex: "F2F0E1"),
            selection: .selectedTextBackgroundColor,
            keywords: Attribute(color: .systemBlue, bold: true),
            commands: Attribute(color: .systemPurple),
            types: Attribute(color: .systemTeal),
            attributes: Attribute(color: .systemOrange),
            variables: Attribute(color: .textColor),
            values: Attribute(color: .systemGreen),
            numbers: Attribute(color: .systemOrange),
            strings: Attribute(color: .systemRed),
            characters: Attribute(color: .systemRed),
            comments: Attribute(color: .secondaryLabelColor, italic: true)
        )
    }
}
