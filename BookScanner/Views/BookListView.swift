import SwiftUI

struct BookListView: View {
    let books: [Book]
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    let library: Library
    
    var body: some View {
        List {
            ForEach(books) { book in
                NavigationLink {
                    BookDetailView(book: book, toggleRead: {
                        toggleRead(book.id)
                    }, isRead: {
                        isRead(book.id)
                    }, library: library)
                } label: {
                    BookRowView(book: book)
                        .overlay(alignment: .topTrailing) {
                            if isRead(book.id) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.green)
                                    .padding(8)
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationView {
        BookListView(
            books: [
                Book(
                    isbn: "123",
                    title: "Sample Book",
                    author: "Author Name",
                    description: "A sample description",
                    coverURL: nil,
                    publishedDate: "2023",
                    isRead: true
                )
            ],
            toggleRead: { _ in },
            isRead: { _ in true },
            library: Library()
        )
    }
}
