import SwiftUI

struct BookRowView: View {
    let book: Book
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack(alignment: .topLeading) {
                // Book Cover
                if let coverURL = book.coverURL, let url = URL(string: coverURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 90)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                        case .failure(_):
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 90)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .foregroundColor(.gray)
                }
                
                // Lent indicator
                if book.lentTo != nil {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .padding(4)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .foregroundColor(.orange)
                        .offset(x: -5, y: -5)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let lentTo = book.lentTo {
                    Text("Lent to: \(lentTo)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.clear)
    }
}

#Preview {
    BookRowView(book: Book(
        isbn: "123",
        title: "Sample Book with a Very Long Title That Should Wrap",
        author: "Author Name",
        description: "A sample description",
        coverURL: nil,
        publishedDate: "2023",
        isRead: false,
        lentTo: "John Doe"
    ))
    .padding()
}
