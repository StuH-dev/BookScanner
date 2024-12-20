import SwiftUI

struct SplashScreenView: View {
    @State private var opacity = 0.0
    @State private var showMainContent = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if !showMainContent {
                ZStack {
                    BackgroundView()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 80))
                            .foregroundColor(ColorTheme.primary)
                            .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("BookVault")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.textPrimary)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .opacity(opacity)
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showMainContent = true
                        }
                    }
                }
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
