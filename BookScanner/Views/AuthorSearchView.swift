import SwiftUI

struct AuthorSearchView: View {
    @ObservedObject var library: Library
    @State private var searchText = ""
    @State private var books: [Book] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    private let googleBooksService = GoogleBooksService()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Enter author name", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Content
                if isSearching {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let error = searchError {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else if books.isEmpty && !searchText.isEmpty {
                    Spacer()
                    Text("No books found")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(books, id: \.isbn) { book in
                                HStack {
                                    NavigationLink {
                                        BookDetailView(book: book, toggleRead: {
                                            library.toggleRead(book)
                                        }, isRead: {
                                            library.isRead(book)
                                        }, library: library)
                                    } label: {
                                        BookRowView(book: book)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // Add a button to add the book to the library
                                    Button(action: {
                                        library.addBook(book)
                                    }) {
                                        Image(systemName: library.books.contains(where: { $0.isbn == book.isbn }) 
                                              ? "checkmark.circle.fill" 
                                              : "plus.circle.fill")
                                            .foregroundColor(library.books.contains(where: { $0.isbn == book.isbn }) 
                                                            ? .green 
                                                            : .blue)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing)
                                }
                                .overlay(alignment: .topTrailing) {
                                    if library.books.contains(where: { $0.isbn == book.isbn }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .padding(8)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(.ultraThinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .navigationTitle("Search by Author")
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchError = nil
        books = []
        
        Task {
            do {
                let results = try await googleBooksService.searchBooksByAuthor(searchText)
                await MainActor.run {
                    books = results
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    searchError = "Error searching for books: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AuthorSearchView(library: Library())
    }
}
