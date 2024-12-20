import SwiftUI

// Separate view for each book row
struct CollectionBookRowView: View {
    let book: Book
    let library: Library
    let collection: String
    
    var body: some View {
        NavigationLink {
            BookDetailView(
                book: book,
                toggleRead: { library.toggleRead(book) },
                isRead: { library.isRead(book) },
                library: library
            )
        } label: {
            BookRowView(book: book, isRead: { library.isRead(book) })
        }
        .contextMenu {
            Button(role: .destructive) {
                library.removeFromCollection(book, collection: collection)
            } label: {
                Label("Remove from Collection", systemImage: "minus.circle")
            }
        }
        .buttonStyle(.plain)
    }
}

struct CollectionDetailView: View {
    @ObservedObject var library: Library
    let collection: String
    @Environment(\.colorScheme) var colorScheme
    @State private var sortOrder: SortOrder = .title
    
    enum SortOrder {
        case title, author, dateAdded, rating
    }
    
    private func sortedBooks(_ books: [Book]) -> [Book] {
        switch sortOrder {
        case .title:
            return books.sorted { $0.title < $1.title }
        case .author:
            return books.sorted { $0.author < $1.author }
        case .dateAdded:
            return books.sorted { $0.dateAdded > $1.dateAdded }
        case .rating:
            return books.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }
    }
    
    var body: some View {
        let books = library.getBooksInCollection(collection)
        let sorted = sortedBooks(books)
        
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sorted) { book in
                    CollectionBookRowView(
                        book: book,
                        library: library,
                        collection: collection
                    )
                }
            }
            .padding()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationTitle(collection)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        sortOrder = .title
                    } label: {
                        Label("Sort by Title", systemImage: sortOrder == .title ? "checkmark" : "")
                    }
                    
                    Button {
                        sortOrder = .author
                    } label: {
                        Label("Sort by Author", systemImage: sortOrder == .author ? "checkmark" : "")
                    }
                    
                    Button {
                        sortOrder = .dateAdded
                    } label: {
                        Label("Sort by Date Added", systemImage: sortOrder == .dateAdded ? "checkmark" : "")
                    }
                    
                    Button {
                        sortOrder = .rating
                    } label: {
                        Label("Sort by Rating", systemImage: sortOrder == .rating ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .imageScale(.large)
                        .foregroundColor(ColorTheme.primary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CollectionDetailView(
            library: Library(),
            collection: "Sample Collection"
        )
    }
}
