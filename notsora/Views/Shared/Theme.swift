import SwiftUI

enum Theme {
    // Primary brand blue (#55ACEE)
    static let twitterBlue = Color(red: 0x55/255, green: 0xAC/255, blue: 0xEE/255)
    // Darker blue for hover/active states (#2B7BB9)
    static let darkBlue = Color(red: 0x2B/255, green: 0x7B/255, blue: 0xB9/255)
    // Light gray page background (#F5F8FA)
    static let background = Color(red: 0xF5/255, green: 0xF8/255, blue: 0xFA/255)
    // White card surfaces
    static let cardBackground = Color.white
    // Near-black primary text (#14171A)
    static let textPrimary = Color(red: 0x14/255, green: 0x17/255, blue: 0x1A/255)
    // Muted secondary text (#657786)
    static let textSecondary = Color(red: 0x65/255, green: 0x77/255, blue: 0x86/255)
    // Subtle border/divider (#E1E8ED)
    static let border = Color(red: 0xE1/255, green: 0xE8/255, blue: 0xED/255)
    // Success green (#17BF63)
    static let success = Color(red: 0x17/255, green: 0xBF/255, blue: 0x63/255)
    // Error/destructive red (#E0245E)
    static let error = Color(red: 0xE0/255, green: 0x24/255, blue: 0x5E/255)
    // Warning amber (#FFAD1F)
    static let warning = Color(red: 0xFF/255, green: 0xAD/255, blue: 0x1F/255)
}
