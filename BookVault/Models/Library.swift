import Foundation

@MainActor
class Library: ObservableObject {
    @Published private(set) var books: [Book] = []
    private let saveKey = "LibraryBooks"
    private let storageService = StorageService.shared
    
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
    
    // MARK: - Storage Operations
    
    private func save() {
        do {
            try storageService.save(books, forKey: saveKey)
        } catch {
            // In a real app, you might want to show an alert to the user
            print("Failed to save library: \(error.localizedDescription)")
        }
    }
    
    private func loadBooks() {
        do {
            books = try storageService.load(forKey: saveKey)
        } catch {
            print("Failed to load library: \(error.localizedDescription)")
            // If load fails, start with an empty library
            books = []
        }
    }
    
    // MARK: - Backup and Restore
    
    func createBackup() {
        do {
            try storageService.createBackup(books: books)
        } catch {
            print("Failed to create backup: \(error.localizedDescription)")
        }
    }
    
    func restoreFromBackup() {
        do {
            books = try storageService.restoreFromBackup()
            save() // Save the restored books as the current library
        } catch {
            print("Failed to restore from backup: \(error.localizedDescription)")
        }
    }
}
