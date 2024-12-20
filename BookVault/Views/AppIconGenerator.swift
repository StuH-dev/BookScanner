import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.orange, .orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Books icon
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 120))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 5)
        }
        .frame(width: 1024, height: 1024) // Maximum size for app icon
        .clipShape(RoundedRectangle(cornerRadius: 224)) // iOS app icon corner radius
    }
}

#Preview {
    AppIcon()
}
