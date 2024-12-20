import SwiftUI

struct BookListView: View {
    @ObservedObject var library: Library
    @Environment(\.colorScheme) var colorScheme
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    @Binding var searchText: String
    @Binding var selectedGenre: String?
    @Binding var authorFilter: String
    @Binding var viewMode: ViewMode
    @State private var showingLentBooks = false
    
    private var filteredBooks: [Book] {
        FilteredBooksHelper.getFilteredBooks(
            books: library.books,
            searchText: searchText,
            selectedGenre: selectedGenre,
            authorFilter: authorFilter
        )
    }
    
    private var lentBooks: [Book] {
        library.books.filter { $0.lentTo != nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats view
            LibraryStatsView(
                totalBooks: library.books.count,
                readBooks: library.books.filter { isRead($0.id) }.count,
                lentBooks: lentBooks.count,
                showingLentBooks: $showingLentBooks
            )
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.adaptiveSurface(colorScheme))
            
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Genre filter
            if !library.books.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(Set(library.books.flatMap { $0.genres })).sorted(), id: \.self) { genre in
                            Button(action: {
                                if selectedGenre == genre {
                                    selectedGenre = nil
                                } else {
                                    selectedGenre = genre
                                }
                            }) {
                                Text(genre)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedGenre == genre ? ColorTheme.primary : ColorTheme.backgroundSecondary)
                                    .foregroundColor(selectedGenre == genre ? .white : ColorTheme.textPrimary)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.adaptiveSurface(colorScheme))
            }
            
            // Books view
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
            .background(Color.adaptiveBackground(colorScheme))
        }
        .navigationTitle("My Books")
        .sheet(isPresented: $showingLentBooks) {
            NavigationView {
                LentBooksView(library: library)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.textSecondary)
            
            TextField("Search books...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(ColorTheme.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .padding(8)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(ColorTheme.separator, lineWidth: 1)
        )
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
