import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    let isbn: String
    var title: String
    var author: String
    var description: String?
    var coverURL: String?
    var publishedDate: String?
    var genres: [String]
    var isRead: Bool
    var lentTo: String?
    var lentDate: Date?
    
    // New fields for enhanced management
    var collections: Set<String>
    var notes: String?
    var dateAdded: Date
    var lastModified: Date
    var rating: Int?  // 1-5 stars
    
    init(isbn: String, title: String, author: String, description: String? = nil,
         coverURL: String? = nil, publishedDate: String? = nil, genres: [String] = [],
         isRead: Bool = false, lentTo: String? = nil, lentDate: Date? = nil,
         collections: Set<String> = [], notes: String? = nil, rating: Int? = nil) {
        self.id = UUID()
        self.isbn = isbn
        self.title = title
        self.author = author
        self.description = description
        self.coverURL = coverURL
        self.publishedDate = publishedDate
        self.genres = genres
        self.isRead = isRead
        self.lentTo = lentTo
        self.lentDate = lentDate
        self.collections = collections
        self.notes = notes
        self.dateAdded = Date()
        self.lastModified = Date()
        self.rating = rating
    }
    
    mutating func update(title: String? = nil, author: String? = nil,
                        description: String? = nil, coverURL: String? = nil,
                        publishedDate: String? = nil, genres: [String]? = nil,
                        isRead: Bool? = nil, lentTo: String? = nil, lentDate: Date? = nil,
                        collections: Set<String>? = nil, notes: String? = nil,
                        rating: Int? = nil) {
        if let title = title { self.title = title }
        if let author = author { self.author = author }
        if let description = description { self.description = description }
        if let coverURL = coverURL { self.coverURL = coverURL }
        if let publishedDate = publishedDate { self.publishedDate = publishedDate }
        if let genres = genres { self.genres = genres }
        if let isRead = isRead { self.isRead = isRead }
        if let lentTo = lentTo { self.lentTo = lentTo }
        if let lentDate = lentDate { self.lentDate = lentDate }
        if let collections = collections { self.collections = collections }
        if let notes = notes { self.notes = notes }
        if let rating = rating { self.rating = rating }
        self.lastModified = Date()
    }
    
    // Helper methods for collections
    mutating func addToCollection(_ collection: String) {
        collections.insert(collection)
        lastModified = Date()
    }
    
    mutating func removeFromCollection(_ collection: String) {
        collections.remove(collection)
        lastModified = Date()
    }
    
    // Helper methods for lending
    mutating func lendTo(_ person: String) {
        self.lentTo = person
        self.lentDate = Date()
        self.lastModified = Date()
    }
    
    mutating func returnBook() {
        self.lentTo = nil
        self.lentDate = nil
        self.lastModified = Date()
    }
}
