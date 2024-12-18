import Foundation

class GoogleBooksService {
    static let shared = GoogleBooksService()
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    
    init() {}
    
    func fetchBookDetails(isbn: String) async throws -> Book {
        let query = "isbn:\(isbn)"
        return try await fetchBook(query: query)
    }
    
    func searchBooksByAuthor(_ author: String) async throws -> [Book] {
        let query = "inauthor:\(author)"
        let urlString = "\(baseURL)?q=\(query)&maxResults=20".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        
        guard let items = response.items else {
            return []
        }
        
        return items.compactMap { volume -> Book? in
            guard let volumeInfo = volume.volumeInfo,
                  let industryIdentifiers = volumeInfo.industryIdentifiers,
                  let isbn = industryIdentifiers.first(where: { $0.type == "ISBN_13" })?.identifier ?? 
                            industryIdentifiers.first(where: { $0.type == "ISBN_10" })?.identifier else {
                return nil
            }
            
            let secureImageURL = volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")
            
            return Book(
                isbn: isbn,
                title: volumeInfo.title,
                author: volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author",
                description: volumeInfo.description,
                coverURL: secureImageURL,
                publishedDate: volumeInfo.publishedDate,
                genres: volumeInfo.categories ?? [],
                isRead: false
            )
        }
    }
    
    private func fetchBook(query: String) async throws -> Book {
        let urlString = "\(baseURL)?q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        
        guard let volumeInfo = response.items?.first?.volumeInfo else {
            throw NSError(domain: "GoogleBooksService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book not found"])
        }
        
        // Convert http thumbnail URLs to https
        let secureImageURL = volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")
        
        return Book(
            isbn: query.replacingOccurrences(of: "isbn:", with: ""),
            title: volumeInfo.title,
            author: volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author",
            description: volumeInfo.description,
            coverURL: secureImageURL,
            publishedDate: volumeInfo.publishedDate,
            genres: volumeInfo.categories ?? [],
            isRead: false
        )
    }
}

// MARK: - Response Models
private struct GoogleBooksResponse: Codable {
    let items: [Volume]?
}

private struct Volume: Codable {
    let volumeInfo: VolumeInfo?
}

private struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let description: String?
    let publishedDate: String?
    let imageLinks: ImageLinks?
    let industryIdentifiers: [IndustryIdentifier]?
    let categories: [String]?
}

private struct ImageLinks: Codable {
    let thumbnail: String?
}

private struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}
