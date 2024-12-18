import Foundation

class LibraryManager: ObservableObject {
    @Published var books: [Book] = []
    private let saveKey = "library_books"
    
    init() {
        loadBooks()
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Book].self, from: data) {
                self.books = decoded
                return
            }
        }
        self.books = []
    }
    
    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    func toggleRead(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].isRead.toggle()
            saveBooks()
        }
    }
    
    func isRead(_ book: Book) -> Bool {
        return books.first(where: { $0.id == book.id })?.isRead ?? false
    }
    
    // Collection Management
    func addToCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].collections.insert(collection)
            saveBooks()
        }
    }
    
    func removeFromCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].collections.remove(collection)
            saveBooks()
        }
    }
    
    func getCollections() -> Set<String> {
        return Set(books.flatMap { $0.collections })
    }
    
    func getBooksInCollection(_ collection: String) -> [Book] {
        return books.filter { $0.collections.contains(collection) }
    }
    
    // Rating Management
    func setRating(_ book: Book, rating: Int) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].rating = rating
            saveBooks()
        }
    }
    
    // Notes Management
    func setNotes(_ book: Book, notes: String) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].notes = notes
            saveBooks()
        }
    }
    
    // Bulk Operations
    func addBooksToCollection(_ books: [Book], collection: String) {
        for book in books {
            addToCollection(book, collection: collection)
        }
    }
    
    func removeBooksFromCollection(_ books: [Book], collection: String) {
        for book in books {
            removeFromCollection(book, collection: collection)
        }
    }
    
    func setRatingForBooks(_ books: [Book], rating: Int) {
        for book in books {
            setRating(book, rating: rating)
        }
    }
}
