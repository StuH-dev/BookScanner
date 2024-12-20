import SwiftUI

struct BookGridView: View {
    let books: [Book]
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    let library: Library
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(books) { book in
                    NavigationLink(destination: BookDetailView(book: book, toggleRead: {
                        toggleRead(book.id)
                    }, isRead: {
                        isRead(book.id)
                    }, library: library)) {
                        BookGridCell(book: book, isRead: { isRead(book.id) })
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button(action: {
                            toggleRead(book.id)
                        }) {
                            Label(
                                isRead(book.id) ? "Mark as Unread" : "Mark as Read",
                                systemImage: isRead(book.id) ? "book.closed" : "book"
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct BookGridCell: View {
    let book: Book
    let isRead: () -> Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Cover Image
                if let coverURL = book.coverURL, let url = URL(string: coverURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .foregroundColor(Color.adaptiveSurface(colorScheme))
                                .aspectRatio(2/3, contentMode: .fit)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(2/3, contentMode: .fit)
                        case .failure:
                            Rectangle()
                                .foregroundColor(Color.adaptiveSurface(colorScheme))
                                .aspectRatio(2/3, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "book.closed.fill")
                                        .foregroundColor(ColorTheme.textSecondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .foregroundColor(Color.adaptiveSurface(colorScheme))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay(
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(ColorTheme.textSecondary)
                        )
                        .cornerRadius(8)
                }
                
                // Read indicator
                if isRead() {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorTheme.success)
                        .background(Color.white.clipShape(Circle()))
                        .padding(8)
                }
                
                // Lent indicator
                if book.lentTo != nil {
                    Image(systemName: "person.fill")
                        .foregroundColor(ColorTheme.accent)
                        .background(Color.white.clipShape(Circle()))
                        .padding(8)
                        .offset(x: 0, y: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineLimit(1)
                
                if !book.genres.isEmpty {
                    Text(book.genres[0])
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.adaptiveSurface(colorScheme))
                        .cornerRadius(4)
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
    NavigationView {
        BookGridView(
            books: [
                Book(
                    isbn: "123",
                    title: "Sample Book with a Very Long Title That Should Wrap",
                    author: "Author Name",
                    description: "A sample description",
                    coverURL: nil,
                    publishedDate: "2023",
                    genres: ["Fiction", "Mystery"],
                    isRead: false,
                    lentTo: "John Doe"
                )
            ],
            toggleRead: { _ in },
            isRead: { _ in false },
            library: Library()
        )
    }
}
