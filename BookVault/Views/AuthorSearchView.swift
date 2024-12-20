import SwiftUI

struct AuthorSearchView: View {
    @ObservedObject var library: Library
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    @State private var books: [Book] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    private let googleBooksService = GoogleBooksService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                TextField("Enter author name", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(Color.adaptiveSurface(colorScheme))
                    .cornerRadius(8)
                    .autocapitalization(.words)
                    .onSubmit {
                        performSearch()
                    }
                
                Button(action: performSearch) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorTheme.primary)
                        .padding(8)
                        .background(Color.adaptiveSurface(colorScheme))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // Content
            if isSearching {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else if let error = searchError {
                Spacer()
                Text(error)
                    .foregroundColor(ColorTheme.error)
                    .padding()
                Spacer()
            } else if books.isEmpty && !searchText.isEmpty {
                Spacer()
                Text("No books found")
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(books) { book in
                            NavigationLink {
                                BookDetailView(
                                    book: book,
                                    toggleRead: { library.toggleRead(book) },
                                    isRead: { library.isRead(book) },
                                    library: library
                                )
                            } label: {
                                HStack {
                                    BookRowView(book: book, isRead: { library.isRead(book) })
                                    
                                    Spacer()
                                    
                                    if library.books.contains(where: { $0.isbn == book.isbn }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ColorTheme.primary)
                                            .padding(.trailing)
                                    } else {
                                        Button {
                                            library.addBook(book)
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(ColorTheme.primary)
                                                .padding(.trailing)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationTitle("Search by Author")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchError = nil
        
        Task {
            do {
                books = try await googleBooksService.searchBooksByAuthor(searchText)
                isSearching = false
            } catch {
                searchError = error.localizedDescription
                isSearching = false
            }
        }
    }
}

#Preview {
    NavigationView {
        AuthorSearchView(library: Library())
    }
}
