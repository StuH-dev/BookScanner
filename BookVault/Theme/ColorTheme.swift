import SwiftUI

struct ColorTheme {
    // Base colors - Modern iOS palette
    static let primary = Color(hex: "007AFF")      // iOS Blue
    static let secondary = Color(hex: "5856D6")    // iOS Purple
    static let accent = Color(hex: "FF9500")       // iOS Orange
    
    // Background colors
    static let backgroundPrimary = Color(hex: "F2F2F7")  // iOS Light Gray
    static let backgroundSecondary = Color(hex: "FFFFFF") // Pure White
    static let backgroundElevated = Color(hex: "FFFFFF")  // Elevated surfaces
    
    // Text colors
    static let textPrimary = Color(hex: "000000")        // Primary text
    static let textSecondary = Color(hex: "3C3C43")      // Secondary text with 60% opacity
    static let textTertiary = Color(hex: "3C3C43")       // Tertiary text with 30% opacity
    
    // Semantic colors - Using iOS system colors
    static let success = Color.green               // System Green
    static let warning = Color.orange              // System Orange
    static let error = Color.red                   // System Red
    
    // Dark mode colors
    static let darkBackgroundPrimary = Color(hex: "1C1C1E")    // Dark Gray
    static let darkBackgroundSecondary = Color(hex: "2C2C2E")  // Slightly lighter Dark Gray
    static let darkBackgroundElevated = Color(hex: "3C3C3E")   // Elevated Dark surfaces
    
    // Modern accents
    static let tint = Color(hex: "007AFF")        // iOS Tint
    static let separator = Color(hex: "3C3C43").opacity(0.2)
    
    // Card and surface colors
    static let surface = Color(hex: "FFFFFF")
    static let surfaceHighlighted = Color(hex: "F2F2F7")
}

extension Color {
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ColorTheme.darkBackgroundPrimary : ColorTheme.backgroundPrimary
    }
    
    static func adaptiveSurface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ColorTheme.darkBackgroundSecondary : ColorTheme.surface
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
