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
