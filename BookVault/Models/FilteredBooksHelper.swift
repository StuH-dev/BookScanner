import Foundation

enum FilteredBooksHelper {
    static func getFilteredBooks(
        books: [Book],
        searchText: String,
        selectedGenre: String?,
        authorFilter: String
    ) -> [Book] {
        var result = books
        
        // Apply genre filter
        if let genre = selectedGenre {
            result = filterByGenre(books: result, genre: genre)
        }
        
        // Apply text search
        if !searchText.isEmpty {
            result = filterBySearchText(books: result, searchText: searchText)
        }
        
        // Apply author filter
        if !authorFilter.isEmpty {
            result = filterByAuthor(books: result, authorFilter: authorFilter)
        }
        
        return result
    }
    
    private static func filterByGenre(books: [Book], genre: String) -> [Book] {
        books.filter { $0.genres.contains(genre) }
    }
    
    private static func filterBySearchText(books: [Book], searchText: String) -> [Book] {
        books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText) ||
            book.author.localizedCaseInsensitiveContains(searchText) ||
            book.genres.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private static func filterByAuthor(books: [Book], authorFilter: String) -> [Book] {
        books.filter { book in
            book.author.localizedCaseInsensitiveContains(authorFilter) ||
            book.title.localizedCaseInsensitiveContains(authorFilter)
        }
    }
}
