import SwiftUI

struct LibraryStatsView: View {
    let totalBooks: Int
    let readBooks: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatBox(title: "Total Books", value: totalBooks)
            StatBox(title: "Books Read", value: readBooks)
            StatBox(title: "Completion", value: totalBooks > 0 ? Int((Double(readBooks) / Double(totalBooks)) * 100) : 0, suffix: "%")
        }
        .padding()
    }
}

struct StatBox: View {
    let title: String
    let value: Int
    var suffix: String = ""
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)\(suffix)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    LibraryStatsView(totalBooks: 10, readBooks: 5)
}
