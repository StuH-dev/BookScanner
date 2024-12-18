import SwiftUI

struct BookGridView: View {
    let books: [Book]
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    @ObservedObject var library: Library
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(books) { book in
                    NavigationLink {
                        BookDetailView(book: book, toggleRead: {
                            toggleRead(book.id)
                        }, isRead: {
                            isRead(book.id)
                        }, library: library)
                    } label: {
                        BookGridCell(book: book, isRead: { isRead(book.id) })
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button {
                            toggleRead(book.id)
                        } label: {
                            Label(isRead(book.id) ? "Mark as Unread" : "Mark as Read",
                                  systemImage: isRead(book.id) ? "bookmark.slash" : "bookmark")
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
        VStack(alignment: .center, spacing: 8) {
            if let coverURL = book.coverURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 225)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 225)
                            .clipped()
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 225)
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(40)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    ZStack(alignment: .top) {
                        if isRead() {
                            HStack {
                                Spacer()
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.green)
                                    .padding(4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .padding(4)
                            }
                        }
                        
                        if book.lentTo != nil {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                                    .padding(4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .padding(4)
                                Spacer()
                            }
                        }
                    }
                }
                .shadow(radius: 4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding(40)
                    )
                    .overlay {
                        ZStack(alignment: .top) {
                            if isRead() {
                                HStack {
                                    Spacer()
                                    Image(systemName: "bookmark.fill")
                                        .foregroundColor(.green)
                                        .padding(4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                            }
                            
                            if book.lentTo != nil {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.orange)
                                        .padding(4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .padding(4)
                                    Spacer()
                                }
                            }
                        }
                    }
            }
            
            VStack(spacing: 4) {
                Text(book.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(book.author)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(height: 60)
        }
        .frame(width: 150)
        .background(Color.clear)
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
