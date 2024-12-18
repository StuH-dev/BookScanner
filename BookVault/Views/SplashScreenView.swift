import SwiftUI

struct SplashScreenView: View {
    @State private var opacity = 0.0
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            if !showMainContent {
                ZStack {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text("BookVault")
                            .font(.largeTitle)
                            .fontWeight(.bold)
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
            }
            
            if showMainContent {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
