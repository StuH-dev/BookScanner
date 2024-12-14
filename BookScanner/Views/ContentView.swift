import SwiftUI

struct ContentView: View {
    @StateObject private var library = Library()
    @State private var viewMode: ViewMode = .grid
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Library Stats
                LibraryStatsView(
                    totalBooks: library.books.count,
                    readBooks: library.books.filter(\.isRead).count
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
                                    BookRowView(book: book)
                                        .overlay(alignment: .topTrailing) {
                                            if book.isRead {
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
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                viewMode = viewMode == .grid ? .list : .grid
                            }
                        } label: {
                            Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                        }
                        
                        NavigationLink(destination: BarcodeScannerView(library: library)) {
                            Label("Scan Book", systemImage: "barcode.viewfinder")
                        }
                        
                        NavigationLink(destination: AuthorSearchView(library: library)) {
                            Label("Search by Author", systemImage: "magnifyingglass")
                        }
                    }
                }
            }
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
