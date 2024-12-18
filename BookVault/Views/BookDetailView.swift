import SwiftUI

struct BookDetailView: View {
    let book: Book
    let toggleRead: () -> Void
    let isRead: () -> Bool
    @ObservedObject var library: Library
    @Environment(\.dismiss) private var dismiss
    @State private var showingLendSheet = false
    @State private var borrowerName = ""
    
    private var isInLibrary: Bool {
        library.books.contains(where: { $0.isbn == book.isbn })
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Cover Image
                    Group {
                        if let coverURL = book.coverURL, let url = URL(string: coverURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 200, height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 300)
                                case .failure(_):
                                    Image(systemName: "book.closed.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 300)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 300)
                                .foregroundColor(.gray)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Author
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(book.author)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Published Date
                        if let publishedDate = book.publishedDate {
                            Text("Published: \(publishedDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // ISBN
                        Text("ISBN: \(book.isbn)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Description
                        if let description = book.description {
                            Text(description)
                                .font(.body)
                                .padding(.top, 8)
                        }
                        
                        // Genres
                        if !book.genres.isEmpty {
                            Text("Genres: \(book.genres.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Lending Status
                        if isInLibrary {
                            VStack(alignment: .leading, spacing: 10) {
                                if let lentTo = book.lentTo {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.orange)
                                        Text("Lent to: \(lentTo)")
                                        Spacer()
                                        Button(action: {
                                            library.returnBook(book)
                                        }) {
                                            Text("Return")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    if let lentDate = book.lentDate {
                                        Text("Since: \(lentDate.formatted(date: .long, time: .omitted))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Button(action: {
                                        showingLendSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "hand.wave.fill")
                                            Text("Lend Book")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        
                        // Add to Library Button
                        if !isInLibrary {
                            Button(action: {
                                library.addBook(book)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Library")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
            }
        }
        .sheet(isPresented: $showingLendSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Borrower Details")) {
                        TextField("Name", text: $borrowerName)
                    }
                }
                .navigationTitle("Lend Book")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingLendSheet = false
                    },
                    trailing: Button("Lend") {
                        if !borrowerName.isEmpty {
                            library.lendBook(book, to: borrowerName)
                            showingLendSheet = false
                        }
                    }
                    .disabled(borrowerName.isEmpty)
                )
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isInLibrary {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        toggleRead()
                    } label: {
                        Image(systemName: isRead() ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isRead() ? .green : .primary)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BookDetailView(
            book: Book(
                isbn: "9781234567890",
                title: "Sample Book",
                author: "Sample Author",
                description: "This is a sample description for the book. It can be quite long and will wrap to multiple lines. The description provides details about the book's content and can help readers decide if they want to read it.",
                coverURL: nil,
                publishedDate: "2023",
                genres: ["Fiction", "Mystery"],
                isRead: false,
                lentTo: nil
            ),
            toggleRead: {},
            isRead: { false },
            library: Library()
        )
    }
}
