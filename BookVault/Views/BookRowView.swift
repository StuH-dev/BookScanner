import SwiftUI

struct BookRowView: View {
    let book: Book
    let isRead: () -> Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Cover Image with Status Indicators
            ZStack(alignment: .topTrailing) {
                // Book Cover
                if let coverURL = book.coverURL, let url = URL(string: coverURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 90)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                        case .failure:
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                                .foregroundColor(ColorTheme.textSecondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(8)
                } else {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .foregroundColor(ColorTheme.textSecondary)
                        .cornerRadius(8)
                }
                
                // Status Indicators
                if isRead() {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .background(Color.white.clipShape(Circle()))
                        .padding(4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                
                if !book.genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(book.genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.adaptiveSurface(colorScheme))
                                    .foregroundColor(ColorTheme.textPrimary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                if let lentTo = book.lentTo {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                        Text("Lent to: \(lentTo)")
                    }
                    .font(.caption)
                    .foregroundColor(ColorTheme.accent)
                }
            }
        }
        .padding()
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    BookRowView(
        book: Book(
            isbn: "9780743273565",
            title: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            description: "A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.",
            genres: ["Fiction", "Classic"],
            lentTo: "John Doe",
            collections: ["Collection 1", "Collection 2"],
            rating: 4
        ),
        isRead: { true }
    )
    .padding()
}
