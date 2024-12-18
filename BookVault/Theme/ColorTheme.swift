import SwiftUI

struct ColorTheme {
    // Darker, more saturated pastel colors for better readability
    static let primary = Color(red: 235/255, green: 175/255, blue: 185/255)    // Deeper rose pink
    static let secondary = Color(red: 160/255, green: 190/255, blue: 235/255)  // Deeper pastel blue
    static let accent = Color(red: 245/255, green: 215/255, blue: 150/255)     // Warmer golden yellow
    static let background = Color(red: 248/255, green: 248/255, blue: 250/255) // Slightly cooler white
    static let text = Color(red: 45/255, green: 45/255, blue: 45/255)          // Darker text for contrast
    
    // Additional semantic colors
    static let success = Color(red: 150/255, green: 200/255, blue: 170/255)    // Muted sage green
    static let warning = Color(red: 240/255, green: 180/255, blue: 140/255)    // Soft coral
    static let error = Color(red: 220/255, green: 130/255, blue: 140/255)      // Muted red
}

// Commented out custom color extensions
/*
extension Color {
    static let customBackground = Color("Background")
    static let customForeground = Color("Foreground")
    static let customAccent = Color.blue
    
    // Semantic colors
    static let customSuccess = Color.green
    static let customWarning = Color.orange
    static let customError = Color.red
}
*/

extension Color {
    static let backgroundLight = Color(hex: "F9F9F9")
    static let backgroundDark = Color(hex: "1C1C1C")
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
