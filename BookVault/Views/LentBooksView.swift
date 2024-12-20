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
                    BookRowView(book: book, isRead: { library.isRead(book) })
                }
            }
            .padding()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationTitle("Lent Books")
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
    LentBooksView(library: Library())
}
