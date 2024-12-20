import SwiftUI

struct LentBooksView: View {
    @ObservedObject var library: Library
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var lentBooks: [Book] {
        library.books.filter { $0.lentTo != nil }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(lentBooks) { book in
                    HStack {
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
                        .buttonStyle(.plain)
                        
                        Button {
                            library.returnBook(book)
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(ColorTheme.primary)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationTitle("Lent Books")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        LentBooksView(library: Library())
    }
    .navigationViewStyle(.stack)
}
