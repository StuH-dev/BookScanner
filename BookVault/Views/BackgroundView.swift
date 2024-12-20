import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground(colorScheme)
                .ignoresSafeArea()
            
            // Create subtle gradient circles for the background
            Circle()
                .fill(ColorTheme.primary.opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 30)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(ColorTheme.secondary.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 40)
                .offset(x: 100, y: -120)
            
            Circle()
                .fill(ColorTheme.accent.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .offset(x: 50, y: 150)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
