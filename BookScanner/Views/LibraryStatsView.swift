import SwiftUI

struct LibraryStatsView: View {
    let totalBooks: Int
    let readBooks: Int
    let lentBooks: Int
    @Binding var showingLentBooks: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            StatView(title: "Total", value: totalBooks, icon: "books.vertical")
            
            Divider()
                .frame(height: 25)
            
            StatView(title: "Read", value: readBooks, icon: "checkmark.circle")
            
            Divider()
                .frame(height: 25)
            
            Button(action: {
                showingLentBooks.toggle()
            }) {
                StatView(title: "Lent", value: lentBooks, icon: "person.fill")
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatView: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LibraryStatsView(totalBooks: 10, readBooks: 5, lentBooks: 2, showingLentBooks: .constant(false))
        .padding()
}
