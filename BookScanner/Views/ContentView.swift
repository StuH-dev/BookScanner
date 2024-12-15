import SwiftUI

struct ContentView: View {
    @StateObject private var library = Library()
    @State private var viewMode: ViewMode = .grid
    @State private var showingScanner = false
    @State private var showingAuthorSearch = false
    @State private var showingLentBooks = false
    @State private var isDarkMode = false
    
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
                    
                    // Book List/Grid
                    if library.books.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Your library is empty")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("Add books by scanning or searching")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        if viewMode == .grid {
                            BookGridView(
                                books: library.books,
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
                                ForEach(library.books) { book in
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
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingAuthorSearch.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        Button {
                            viewMode = viewMode == .grid ? .list : .grid
                        } label: {
                            Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                        }
                        
                        Button {
                            showingScanner.toggle()
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                        }
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
