import SwiftUI

struct CollectionsView: View {
    @ObservedObject var library: Library
    @State private var newCollectionName: String = ""
    @State private var showingAddCollection = false
    
    var body: some View {
        List {
            Section(header: Text("Collections")) {
                ForEach(Array(library.getCollections()).sorted(), id: \.self) { collection in
                    NavigationLink(destination: CollectionDetailView(library: library, collection: collection)) {
                        HStack {
                            Text(collection)
                            Spacer()
                            Text("\(library.getBooksInCollection(collection).count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteCollections)
            }
        }
        .navigationTitle("Collections")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCollection = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Collection", isPresented: $showingAddCollection) {
            TextField("Collection Name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newCollectionName.isEmpty {
                    // Add an empty collection by adding it to a temporary book and removing the book
                    let tempBook = Book(isbn: "temp", title: "temp", author: "temp", collections: [newCollectionName])
                    library.addBook(tempBook)
                    library.removeBook(tempBook)
                    newCollectionName = ""
                }
            }
        }
    }
    
    private func deleteCollections(at offsets: IndexSet) {
        let collectionsToDelete = offsets.map { Array(library.getCollections()).sorted()[$0] }
        for collection in collectionsToDelete {
            let booksInCollection = library.getBooksInCollection(collection)
            for book in booksInCollection {
                library.removeFromCollection(book, collection: collection)
            }
        }
    }
}

struct CollectionDetailView: View {
    @ObservedObject var library: Library
    let collection: String
    @State private var selectedBooks: Set<UUID> = []
    @State private var showingBulkActions = false
    @State private var sortOrder: SortOrder = .title
    
    enum SortOrder {
        case title, author, dateAdded, rating
    }
    
    var sortedBooks: [Book] {
        let books = library.getBooksInCollection(collection)
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
        List(sortedBooks) { book in
            BookRowView(book: book)
                .swipeActions {
                    Button(role: .destructive) {
                        library.removeFromCollection(book, collection: collection)
                    } label: {
                        Label("Remove", systemImage: "minus.circle")
                    }
                }
        }
        .navigationTitle(collection)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Sort by Title") {
                        sortOrder = .title
                    }
                    Button("Sort by Author") {
                        sortOrder = .author
                    }
                    Button("Sort by Date Added") {
                        sortOrder = .dateAdded
                    }
                    Button("Sort by Rating") {
                        sortOrder = .rating
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }
}
