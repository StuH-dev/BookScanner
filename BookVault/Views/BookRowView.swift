import SwiftUI

struct BookRowView: View {
    let book: Book
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack(alignment: .topLeading) {
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
                                .cornerRadius(8) // Adds rounded corners to the image
                        case .failure(_):
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                                .cornerRadius(8) // Adds rounded corners to the fallback
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .cornerRadius(8) // Adds rounded corners
                        .foregroundColor(.gray)
                }
                
                // Lent indicator
                if book.lentTo != nil {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .padding(4)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .foregroundColor(.orange)
                        .offset(x: -5, y: -5)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if !book.genres.isEmpty {
                    HStack {
                        ForEach(book.genres.prefix(2), id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                        if book.genres.count > 2 {
                            Text("+\(book.genres.count - 2)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let lentTo = book.lentTo {
                    Text("Lent to: \(lentTo)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    colorScheme == .dark
                    ? Color(uiColor: .secondarySystemBackground) // Dark mode support
                    : Color(uiColor: .systemBackground) // Light mode support
                )
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Adds a subtle shadow
        )
        .padding(.horizontal)
    }
}

#Preview {
    BookRowView(book: Book(
        isbn: "123",
        title: "Sample Book with a Very Long Title That Should Wrap",
        author: "Author Name",
        description: "A sample description",
        coverURL: nil,
        publishedDate: "2023",
        genres: ["Fiction", "Thriller", "Mystery"],
        isRead: false,
        lentTo: "John Doe"
    ))
    .padding()
}
