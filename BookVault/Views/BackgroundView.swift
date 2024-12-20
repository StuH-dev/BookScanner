import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground(colorScheme)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                // Top gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.primary.opacity(0.1),
                                ColorTheme.secondary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.7)
                    .offset(x: -geometry.size.width * 0.2, y: -geometry.size.height * 0.2)
                    .blur(radius: 50)
                
                // Bottom gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.accent.opacity(0.1),
                                ColorTheme.primary.opacity(0.05)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        )
                    )
                    .frame(width: geometry.size.width * 0.8)
                    .offset(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2)
                    .blur(radius: 50)
            }
        }
        .background(Color.adaptiveBackground(colorScheme))
    }
}

#Preview {
    BackgroundView()
}
