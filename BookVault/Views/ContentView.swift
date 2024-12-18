import SwiftUI

struct ContentView: View {
    @StateObject private var library = Library()
    @State private var viewMode: ViewMode = .grid
    @State private var showingScanner = false
    @State private var showingAuthorSearch = false
    @State private var showingLentBooks = false
    @State private var isDarkMode = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var searchText = ""
    @State private var selectedGenre: String?
    @State private var authorFilter = ""
    
    var availableGenres: [String] {
        Array(Set(library.books.flatMap { $0.genres })).sorted()
    }
    
    var filteredBooks: [Book] {
        var books = library.books
        
        // Apply genre filter
        if let genre = selectedGenre {
            books = books.filter { $0.genres.contains(genre) }
        }
        
        // Apply text search
        if !searchText.isEmpty {
            books = books.filter { book in
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.genres.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply author filter
        if !authorFilter.isEmpty {
            books = books.filter { book in
                book.author.localizedCaseInsensitiveContains(authorFilter) ||
                book.title.localizedCaseInsensitiveContains(authorFilter)
            }
        }
        
        return books
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add background
                BackgroundView()
                
                VStack(spacing: 20) {
                    // Library Stats
                    LibraryStatsView(
                        totalBooks: library.books.count,
                        readBooks: library.books.filter(\.isRead).count,
                        lentBooks: library.books.filter { $0.lentTo != nil }.count,
                        showingLentBooks: $showingLentBooks
                    )
                    .padding(.horizontal)
                    
                    // Search and Filter Section
                    VStack(spacing: 12) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search by title, author, or genre...", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Genre filter
                        if !availableGenres.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(availableGenres, id: \.self) { genre in
                                        Button(action: {
                                            if selectedGenre == genre {
                                                selectedGenre = nil
                                            } else {
                                                selectedGenre = genre
                                            }
                                        }) {
                                            Text(genre)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    selectedGenre == genre ?
                                                    Color.blue :
                                                    Color.gray.opacity(0.2)
                                                )
                                                .foregroundColor(
                                                    selectedGenre == genre ?
                                                    .white :
                                                    .primary
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Book List/Grid
                    if filteredBooks.isEmpty {
                        VStack(spacing: 20) {
                            if library.books.isEmpty {
                                Image(systemName: "books.vertical")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Your library is empty")
                                    .font(.headline)
                                Text("Tap the scan button to add books")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No books found")
                                    .font(.headline)
                                Text("Try different search terms or filters")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    } else {
                        if viewMode == .grid {
                            BookGridView(
                                books: filteredBooks,
                                toggleRead: { id in
                                    if let book = library.books.first(where: { $0.id == id }) {
                                        library.toggleRead(book)
                                    }
                                },
                                isRead: { id in
                                    library.books.first(where: { $0.id == id })?.isRead ?? false
                                },
                                library: library
                            )
                        } else {
                            List {
                                ForEach(filteredBooks) { book in
                                    NavigationLink(destination: BookDetailView(book: book, toggleRead: {
                                        library.toggleRead(book)
                                    }, isRead: {
                                        library.isRead(book)
                                    }, library: library)) {
                                        HStack {
                                            BookRowView(book: book)
                                            
                                            Spacer()
                                            
                                            if book.isRead {
                                                Image(systemName: "bookmark.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteBooks)
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingScanner.toggle()
                        }) {
                            Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        }
                        
                        Button(action: {
                            showingAuthorSearch.toggle()
                        }) {
                            Label("Search by Author", systemImage: "magnifyingglass")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewMode = viewMode == .grid ? .list : .grid
                        }) {
                            Label(
                                viewMode == .grid ? "List View" : "Grid View",
                                systemImage: viewMode == .grid ? "list.bullet" : "square.grid.2x2"
                            )
                        }
                        
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Label(
                                isDarkMode ? "Light Mode" : "Dark Mode",
                                systemImage: isDarkMode ? "sun.max" : "moon"
                            )
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showingBackupAlert = true
                        }) {
                            Label("Backup Library", systemImage: "arrow.up.doc")
                        }
                        
                        Button(action: {
                            showingRestoreAlert = true
                        }) {
                            Label("Restore Library", systemImage: "arrow.down.doc")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingScanner.toggle()
                    }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingScanner) {
            BarcodeScannerView(library: library)
        }
        .sheet(isPresented: $showingAuthorSearch) {
            AuthorSearchView(library: library)
        }
        .sheet(isPresented: $showingLentBooks) {
            LentBooksView(library: library)
        }
        .alert("Backup Library", isPresented: $showingBackupAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Backup") {
                library.createBackup()
            }
        } message: {
            Text("Create a backup of your library?")
        }
        .alert("Restore Library", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) {
                library.restoreFromBackup()
            }
        } message: {
            Text("Restore your library from the last backup? This will replace your current library.")
        }
    }
    
    private func deleteBooks(at offsets: IndexSet) {
        let booksToRemove = offsets.map { library.books[$0] }
        booksToRemove.forEach { book in
            library.removeBook(book)
        }
    }
}

enum ViewMode {
    case list
    case grid
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
