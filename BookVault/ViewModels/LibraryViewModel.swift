import Foundation
import SwiftUI

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var showDuplicateAlert = false
    @Published var duplicateBook: Book? = nil
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let googleBooksService = GoogleBooksService()
    private let userDefaultsKey = "savedBooks"
    
    init() {
        loadBooks()
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            books = savedBooks
        }
    }
    
    private func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    // Statistics properties
    var totalBooks: Int {
        books.count
    }
    
    var booksRead: Int {
        books.filter { $0.isRead }.count
    }
    
    var readingProgress: Double {
        guard totalBooks > 0 else { return 0 }
        return Double(booksRead) / Double(totalBooks)
    }
    
    func scanBarcode(isbn: String) async {
        do {
            // Check for duplicate before fetching
            if let existingBook = books.first(where: { $0.isbn == isbn }) {
                await MainActor.run {
                    duplicateBook = existingBook
                    showDuplicateAlert = true
                }
                return
            }
            
            let book = try await googleBooksService.fetchBookDetails(isbn: isbn)
            
            await MainActor.run {
                addBook(book)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func addBook(_ book: Book) {
        // Check for duplicates
        if books.contains(where: { $0.isbn == book.isbn }) {
            duplicateBook = book
            showDuplicateAlert = true
            return
        }
        
        books.append(book)
        saveBooks()
    }
    
    func addDuplicateAnyway() {
        if let book = duplicateBook {
            books.append(book)
            saveBooks()
            duplicateBook = nil
            showDuplicateAlert = false
        }
    }
    
    func removeBook(id: UUID) {
        books.removeAll { $0.id == id }
        saveBooks()
    }
    
    func toggleReadStatus(for id: UUID) {
        if let index = books.firstIndex(where: { $0.id == id }) {
            books[index].isRead.toggle()
            saveBooks()
        }
    }
    
    func removeBooks(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
        saveBooks()
    }
}

// MARK: - Error Handling
extension LibraryViewModel {
    enum LibraryError: LocalizedError {
        case duplicateBook
        case bookNotFound
        case invalidISBN
        
        var errorDescription: String? {
            switch self {
            case .duplicateBook:
                return "This book is already in your library"
            case .bookNotFound:
                return "Could not find book with this ISBN"
            case .invalidISBN:
                return "Invalid ISBN format"
            }
        }
    }
}
