import SwiftUI

struct BookGridItemView: View {
    let book: Book
    
    var body: some View {
        VStack {
            if let coverURL = book.coverURL,
               let url = URL(string: coverURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "book.closed")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.caption)
                    .lineLimit(2)
                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    BookGridItemView(book: Book(
        isbn: "1234567890",
        title: "Sample Book",
        author: "Sample Author",
        genres: ["Fiction"]
    ))
    .frame(width: 150)
    .padding()
}
