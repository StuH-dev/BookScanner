import SwiftUI

struct BookDetailView: View {
    let book: Book
    let toggleRead: () -> Void
    let isRead: () -> Bool
    @ObservedObject var library: Library
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingLendSheet = false
    @State private var showingCollectionSheet = false
    @State private var borrowerName = ""
    @State private var selectedCollections: Set<String> = []
    @State private var showingDeleteAlert = false
    
    private var isInLibrary: Bool {
        library.books.contains(where: { $0.isbn == book.isbn })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cover Image and Rating
                VStack(spacing: 16) {
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
                                        .foregroundColor(ColorTheme.textSecondary)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 300)
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    if isInLibrary {
                        RatingView(
                            rating: book.rating ?? 0,
                            onRatingChanged: { newRating in
                                library.updateBookRating(book, rating: newRating)
                            },
                            size: 24,
                            spacing: 8
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Author
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    
                    // Published Date and ISBN
                    VStack(alignment: .leading, spacing: 4) {
                        if let publishedDate = book.publishedDate {
                            Text("Published: \(publishedDate)")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        Text("ISBN: \(book.isbn)")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Description
                    if let description = book.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(ColorTheme.textPrimary)
                            .padding(.top, 8)
                    }
                    
                    // Genres
                    if !book.genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(book.genres, id: \.self) { genre in
                                    Text(genre)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(ColorTheme.backgroundSecondary)
                                        .foregroundColor(ColorTheme.textPrimary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(ColorTheme.separator, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    if isInLibrary {
                        VStack(spacing: 12) {
                            Button(action: toggleRead) {
                                HStack {
                                    Image(systemName: isRead() ? "book.closed.fill" : "book")
                                    Text(isRead() ? "Mark as Unread" : "Mark as Read")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { showingLendSheet = true }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text(book.lentTo == nil ? "Lend Book" : "Update Loan")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.adaptiveBackground(colorScheme))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isInLibrary {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingCollectionSheet = true }) {
                            Label("Add to Collection", systemImage: "folder.badge.plus")
                        }
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(ColorTheme.primary)
                    }
                }
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
                        borrowerName = ""
                    },
                    trailing: Button("Lend") {
                        if !borrowerName.isEmpty {
                            library.lendBook(book, to: borrowerName)
                            showingLendSheet = false
                            borrowerName = ""
                        }
                    }
                    .disabled(borrowerName.isEmpty)
                )
            }
        }
        .sheet(isPresented: $showingCollectionSheet) {
            NavigationView {
                List {
                    ForEach(Array(library.getCollections()).sorted(), id: \.self) { collection in
                        Button(action: {
                            if selectedCollections.contains(collection) {
                                selectedCollections.remove(collection)
                                library.removeFromCollection(book, collection: collection)
                            } else {
                                selectedCollections.insert(collection)
                                library.addToCollection(book, collection: collection)
                            }
                        }) {
                            HStack {
                                Text(collection)
                                Spacer()
                                if selectedCollections.contains(collection) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Collections")
                .navigationBarItems(
                    trailing: Button("Done") {
                        showingCollectionSheet = false
                    }
                )
            }
        }
        .alert("Remove Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                library.removeBook(book)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to remove '\(book.title)' from your library? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationView {
        BookDetailView(
            book: Book(
                isbn: "1234567890",
                title: "Sample Book",
                author: "Sample Author",
                description: "A sample book description that goes on for a while to test the layout.",
                genres: ["Fiction", "Adventure"]
            ),
            toggleRead: {},
            isRead: { false },
            library: Library()
        )
    }
}
