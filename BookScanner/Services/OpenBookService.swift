import Foundation

enum OpenBookError: Error {
    case invalidURL
    case networkError
    case decodingError
    case noData
}

class OpenBookService {
    static let shared = OpenBookService()
    private let baseURL = "https://openlibrary.org"
    
    private init() {}
    
    func fetchBookDetails(isbn: String) async throws -> Book {
        guard let url = URL(string: "\(baseURL)/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data") else {
            throw OpenBookError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the JSON response and create a Book object
        // Note: This is a simplified version. You'll need to adjust the parsing based on the actual API response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bookData = json["ISBN:\(isbn)"] as? [String: Any],
              let title = bookData["title"] as? String,
              let authors = bookData["authors"] as? [[String: Any]],
              let author = authors.first?["name"] as? String else {
            throw OpenBookError.decodingError
        }
        
        let description = (bookData["description"] as? [String: Any])?["value"] as? String
        let coverURL = (bookData["cover"] as? [String: Any])?["large"] as? String
        let publishedDate = bookData["publish_date"] as? String
        
        return Book(isbn: isbn,
                   title: title,
                   author: author,
                   description: description,
                   coverURL: coverURL,
                   publishedDate: publishedDate)
    }
}
