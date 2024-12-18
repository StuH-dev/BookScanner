import SwiftUI

struct LentBooksView: View {
    @ObservedObject var library: Library
    @Environment(\.dismiss) private var dismiss
    
    var lentBooks: [Book] {
        library.books.filter { $0.lentTo != nil }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                if lentBooks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("No Books Lent")
                            .font(.title2)
                        
                        Text("All your books are home!")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(lentBooks) { book in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        // Book cover
                                        if let coverURL = book.coverURL,
                                           let url = URL(string: coverURL) {
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
                                                case .failure:
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
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(book.title)
                                                .font(.headline)
                                            
                                            if let lentTo = book.lentTo {
                                                Text("Lent to: \(lentTo)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.orange)
                                            }
                                            
                                            if let lentDate = book.lentDate {
                                                Text("Since: \(lentDate.formatted(date: .long, time: .omitted))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            library.returnBook(book)
                                        }) {
                                            Text("Return")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Lent Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LentBooksView(library: Library())
}
