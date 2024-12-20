import Foundation

@MainActor
class Library: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published private var collections: Set<String> = []
    private let saveKey = "LibraryBooks"
    private let collectionsKey = "LibraryCollections"
    private let storageService = StorageService.shared
    private let backupKey = "LibraryBackup"

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
        saveBooks()
    }
    
    func removeBook(_ book: Book) {
        books.removeAll(where: { $0.isbn == book.isbn })
        // Update collections
        updateCollectionsAfterBookChange()
        saveBooks()
    }
    
    func toggleRead(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].isRead.toggle()
            saveBooks()
        }
    }
    
    func lendBook(_ book: Book, to person: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].lendTo(person)
            saveBooks()
        }
    }
    
    func returnBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].returnBook()
            saveBooks()
        }
    }
    
    func isRead(_ book: Book) -> Bool {
        books.first(where: { $0.isbn == book.isbn })?.isRead ?? false
    }
    
    // Collection Management
    func addCollection(_ name: String) {
        collections.insert(name)
        saveCollections()
    }
    
    func removeCollection(_ name: String) {
        collections.remove(name)
        // Remove the collection from all books
        for (index, book) in books.enumerated() {
            if book.collections.contains(name) {
                books[index].removeFromCollection(name)
            }
        }
        saveBooks()
        saveCollections()
    }
    
    func addToCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].addToCollection(collection)
            collections.insert(collection)
            saveBooks()
            saveCollections()
        }
    }
    
    func removeFromCollection(_ book: Book, collection: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
            books[index].removeFromCollection(collection)
            updateCollectionsAfterBookChange()
            saveBooks()
            saveCollections()
        }
    }
    
    func renameCollection(from oldName: String, to newName: String) {
        if oldName != newName {
            for (index, book) in books.enumerated() {
                if book.collections.contains(oldName) {
                    books[index].removeFromCollection(oldName)
                    books[index].addToCollection(newName)
                }
            }
            collections.remove(oldName)
            collections.insert(newName)
            saveBooks()
            saveCollections()
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
            saveBooks()
        }
    }
    
    func updateBookRating(_ book: Book, rating: Int) {
        if var bookToUpdate = books.first(where: { $0.id == book.id }) {
            bookToUpdate.update(rating: rating)
            if let index = books.firstIndex(where: { $0.id == book.id }) {
                books[index] = bookToUpdate
                saveBooks()
            }
        }
    }
    
    // Notes Management
    func setNotes(_ book: Book, notes: String) {
        if let index = books.firstIndex(where: { $0.isbn == book.isbn }) {
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
    
    // MARK: - Private Methods
    
    private func updateCollectionsAfterBookChange() {
        // Get all collections currently in use
        let usedCollections = Set(books.flatMap { $0.collections })
        // Update collections to only include those that are in use
        collections = usedCollections
    }
    
    private func loadBooks() {
        do {
            books = try storageService.load(forKey: saveKey)
            updateCollectionsAfterBookChange()
        } catch {
            print("Failed to load books: \(error.localizedDescription)")
            books = []
        }
    }
    
    private func loadCollections() {
        if let data = UserDefaults.standard.data(forKey: collectionsKey),
           let loadedCollections = try? JSONDecoder().decode(Set<String>.self, from: data) {
            collections = loadedCollections
        }
    }
    
    private func saveBooks() {
        do {
            try storageService.save(books, forKey: saveKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    private func saveCollections() {
        if let data = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(data, forKey: collectionsKey)
        }
    }
    
    // Backup and Restore
    func createBackup() {
        do {
            try storageService.save(books, forKey: backupKey)
            if let data = try? JSONEncoder().encode(collections) {
                UserDefaults.standard.set(data, forKey: "\(backupKey)_collections")
            }
        } catch {
            print("Failed to create backup: \(error.localizedDescription)")
        }
    }
    
    func restoreFromBackup() {
        do {
            books = try storageService.load(forKey: backupKey)
            if let data = UserDefaults.standard.data(forKey: "\(backupKey)_collections"),
               let restoredCollections = try? JSONDecoder().decode(Set<String>.self, from: data) {
                collections = restoredCollections
            }
            saveBooks()
            saveCollections()
        } catch {
            print("Failed to restore from backup: \(error.localizedDescription)")
        }
    }
}
