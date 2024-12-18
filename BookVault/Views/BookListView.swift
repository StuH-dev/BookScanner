import SwiftUI

struct BookListView: View {
    @ObservedObject var library: Library
    let toggleRead: (UUID) -> Void
    let isRead: (UUID) -> Bool
    
    // Define grid layout columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(library.books) { book in
                    NavigationLink {
                        BookDetailView(book: book, toggleRead: {
                            toggleRead(book.id)
                        }, isRead: {
                            isRead(book.id)
                        }, library: library)
                    } label: {
                        BookRowView(book: book)
                            .frame(height: 150) // Set a consistent height for grid items
                            .overlay(alignment: .topTrailing) {
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
            }
            .padding(.horizontal)
        }
        .background(Color(uiColor: .secondarySystemBackground)) // Modern background
        .navigationTitle("My Books")
    }
}

#Preview {
    NavigationView {
        BookListView(
            library: Library(),
            toggleRead: { _ in },
            isRead: { _ in true }
        )
    }
}
