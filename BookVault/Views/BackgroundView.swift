import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            // Create gradient circles for the background
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 250, height: 250)
                .blur(radius: 30)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 40)
                .offset(x: 100, y: 150)
            
            Circle()
                .fill(Color.indigo.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 25)
                .offset(x: 150, y: -200)
            
            // Add a subtle overlay
            Rectangle()
                .fill(colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.4))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
