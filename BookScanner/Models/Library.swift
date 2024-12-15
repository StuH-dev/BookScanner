import Foundation

@MainActor
class Library: ObservableObject {
    @Published private(set) var books: [Book] = []
    private let saveKey = "LibraryBooks"
    
    init() {
        loadBooks()
    }
    
    func addBook(_ book: Book) {
        // Check if book already exists
        guard !books.contains(where: { $0.isbn == book.isbn }) else { return }
        books.append(book)
        save()
    }
    
    func removeBook(_ book: Book) {
        books.removeAll(where: { $0.isbn == book.isbn })
        save()
    }
    
    func toggleRead(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].isRead.toggle()
            save()
        }
    }
    
    func lendBook(_ book: Book, to person: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].lentTo = person
            books[index].lentDate = Date()
            save()
        }
    }
    
    func returnBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].lentTo = nil
            books[index].lentDate = nil
            save()
        }
    }
    
    func isRead(_ book: Book) -> Bool {
        books.first(where: { $0.isbn == book.isbn })?.isRead ?? false
    }
    
    func isLent(_ book: Book) -> Bool {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            return books[index].lentTo != nil
        }
        return false
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
    }
}
