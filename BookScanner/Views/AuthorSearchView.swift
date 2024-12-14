import SwiftUI

struct AuthorSearchView: View {
    @ObservedObject var library: Library
    @State private var searchText = ""
    @State private var books: [Book] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    private let googleBooksService = GoogleBooksService()
    
    var body: some View {
        VStack {
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
            
            if isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if books.isEmpty && !searchText.isEmpty {
                Text("No books found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(books, id: \.isbn) { book in
                            NavigationLink(destination: BookDetailView(book: book, toggleRead: {
                                library.toggleRead(book)
                            }, isRead: {
                                library.isRead(book)
                            }, library: library)) {
                                BookRowView(book: book)
                                    .overlay(alignment: .topTrailing) {
                                        if library.books.contains(where: { $0.isbn == book.isbn }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .padding(8)
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Author Search")
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
