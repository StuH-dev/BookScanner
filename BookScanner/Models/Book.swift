import Foundation

struct Book: Identifiable, Hashable, Codable {
    let id = UUID()
    let isbn: String
    let title: String
    let author: String
    let description: String?
    let coverURL: String?
    let publishedDate: String?
    var isRead: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(isbn)
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.isbn == rhs.isbn
    }
    
    init(isbn: String, title: String, author: String, description: String? = nil, coverURL: String? = nil, publishedDate: String? = nil, isRead: Bool = false) {
        self.isbn = isbn
        self.title = title
        self.author = author
        self.description = description
        self.coverURL = coverURL
        self.publishedDate = publishedDate
        self.isRead = isRead
    }
}
