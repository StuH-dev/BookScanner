import SwiftUI

struct BookListView: View {
    @ObservedObject var library: Library
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    @Binding var searchText: String
    @Binding var selectedGenre: String?
    @Binding var authorFilter: String
    @Binding var viewMode: ViewMode
    
    private var filteredBooks: [Book] {
        FilteredBooksHelper.getFilteredBooks(
            books: library.books,
            searchText: searchText,
            selectedGenre: selectedGenre,
            authorFilter: authorFilter
        )
    }
    
    var body: some View {
        Group {
            if viewMode == .grid {
                BookGridView(
                    books: filteredBooks,
                    toggleRead: toggleRead,
                    isRead: isRead,
                    library: library
                )
            } else {
                BookTableView(
                    books: filteredBooks,
                    library: library,
                    toggleRead: toggleRead,
                    isRead: isRead
                )
            }
        }
        .background(Color(uiColor: .secondarySystemBackground)) // Modern background
        .navigationTitle("My Books")
    }
}

struct BookTableView: View {
    let books: [Book]
    @ObservedObject var library: Library
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    
    var body: some View {
        List(books) { book in
            NavigationLink {
                BookDetailView(book: book, toggleRead: {
                    toggleRead(book.id)
                }, isRead: {
                    isRead(book.id)
                }, library: library)
            } label: {
                BookRowView(book: book)
                    .overlay(alignment: .trailing) {
                        if isRead(book.id) {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .transition(.scale)
                                .animation(.easeInOut(duration: 0.3), value: isRead(book.id))
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
            library: Library(),
            toggleRead: { _ in },
            isRead: { _ in true },
            searchText: .constant(""),
            selectedGenre: .constant(nil),
            authorFilter: .constant(""),
            viewMode: .constant(.grid)
        )
    }
}
