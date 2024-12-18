import Foundation

@MainActor
class Library: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published private var collections: Set<String> = []
    private let saveKey = "LibraryBooks"
    private let collectionsKey = "LibraryCollections"
    private let storageService = StorageService.shared
    
    init() {
        loadBooks()
        loadCollections()
    }
    
    func addBook(_ book: Book) {
        // Check if book already exists
        guard !books.contains(where: { $0.isbn == book.isbn }) else { return }
        books.append(book)
        // Add any new collections from the book
        collections.formUnion(book.collections)
        save()
    }
    
    func removeBook(_ book: Book) {
        books.removeAll(where: { $0.isbn == book.isbn })
        // Update collections
        updateCollectionsAfterBookChange()
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
            books[index].lendTo(person)
            save()
        }
    }
    
    func returnBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].returnBook()
            save()
        }
    }
    
    func isRead(_ book: Book) -> Bool {
        books.first(where: { $0.isbn == book.isbn })?.isRead ?? false
    }
    
    // Collection Management
    func addCollection(_ name: String) {
        collections.insert(name)
        save()
    }
    
    func removeCollection(_ name: String) {
        collections.remove(name)
        // Remove the collection from all books
        for (index, book) in books.enumerated() {
            if book.collections.contains(name) {
                books[index].removeFromCollection(name)
            }
        }
        save()
    }
    
    func addToCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].addToCollection(collection)
            collections.insert(collection)
            save()
        }
    }
    
    func removeFromCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].removeFromCollection(collection)
            updateCollectionsAfterBookChange()
            save()
        }
    }
    
    func getCollections() -> Set<String> {
        return collections
    }
    
    func getBooksInCollection(_ collection: String) -> [Book] {
        return books.filter { $0.collections.contains(collection) }
    }
    
    // Rating Management
    func setRating(_ book: Book, rating: Int) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].rating = rating
            save()
        }
    }
    
    // Notes Management
    func setNotes(_ book: Book, notes: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].notes = notes
            save()
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
    
    // MARK: - Private Methods
    
    private func updateCollectionsAfterBookChange() {
        // Get all collections currently in use
        let usedCollections = Set(books.flatMap { $0.collections })
        // Update collections to only include those that are in use
        collections = usedCollections
    }
    
    private func loadBooks() {
        if let loadedBooks: [Book] = storageService.load(forKey: saveKey) {
            books = loadedBooks
            updateCollectionsAfterBookChange()
        }
    }
    
    private func loadCollections() {
        if let loadedCollections: Set<String> = storageService.load(forKey: collectionsKey) {
            collections = loadedCollections
        }
    }
    
    private func save() {
        storageService.save(books, forKey: saveKey)
        storageService.save(collections, forKey: collectionsKey)
    }
    
    // Backup and Restore
    func createBackup() {
        storageService.createBackup(data: books, forKey: saveKey)
        storageService.createBackup(data: collections, forKey: collectionsKey)
    }
    
    func restoreFromBackup() {
        if let restoredBooks: [Book] = storageService.restoreFromBackup(forKey: saveKey) {
            books = restoredBooks
        }
        if let restoredCollections: Set<String> = storageService.restoreFromBackup(forKey: collectionsKey) {
            collections = restoredCollections
        }
        save()
    }
}
