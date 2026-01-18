//
//  NSColor+Hex.swift
//  ScribblePad
//

import AppKit

extension NSColor {

    /// Initializes a `NSColor` from a HEX String (e.g.: `#1D2E3F`) and an optional alpha value.
    /// - Parameters:
    ///   - hex: A String of a HEX representation of a color (format: `#1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    convenience init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Initializes a `NSColor` from an Int  (e.g.: `0x1D2E3F`)and an optional alpha value.
    /// - Parameters:
    ///   - hex: An Int of a HEX representation of a color (format: `0x1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    convenience init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(srgbRed: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: alpha)
    }
}
