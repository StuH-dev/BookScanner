import Foundation

@MainActor
class Library: ObservableObject {
    @Published private(set) var books: [Book] = []
    
    func addBook(_ book: Book) {
        // Check if book already exists
        guard !books.contains(where: { $0.isbn == book.isbn }) else { return }
        books.append(book)
    }
    
    func removeBook(_ book: Book) {
        books.removeAll(where: { $0.isbn == book.isbn })
    }
    
    func toggleRead(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].isRead.toggle()
        }
    }
    
    func isRead(_ book: Book) -> Bool {
        books.first(where: { $0.isbn == book.isbn })?.isRead ?? false
    }
}
