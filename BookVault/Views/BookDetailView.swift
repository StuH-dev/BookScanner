import SwiftUI

struct BookDetailView: View {
    let book: Book
    let toggleRead: () -> Void
    let isRead: () -> Bool
    @ObservedObject var library: Library
    @Environment(\.dismiss) private var dismiss
    @State private var showingLendSheet = false
    @State private var showingCollectionSheet = false
    @State private var borrowerName = ""
    @State private var selectedCollections: Set<String> = []
    @State private var showingDeleteAlert = false
    
    private var isInLibrary: Bool {
        library.books.contains(where: { $0.isbn == book.isbn })
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
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
                        
                        // Collections
                        if isInLibrary {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Collections")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        selectedCollections = book.collections
                                        showingCollectionSheet = true
                                    }) {
                                        Image(systemName: "folder.badge.plus")
                                    }
                                }
                                
                                if book.collections.isEmpty {
                                    Text("Not in any collections")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(Array(book.collections).sorted(), id: \.self) { collection in
                                                Text(collection)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
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
                                        Button("Return") {
                                            library.returnBook(book)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                } else {
                                    Button(action: { showingLendSheet = true }) {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                            Text("Lend Book")
                                        }
                                    }
                                }
                            }
                        }
                    }
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
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isInLibrary {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            toggleRead()
                        } label: {
                            Label(
                                isRead() ? "Mark as Unread" : "Mark as Read",
                                systemImage: isRead() ? "bookmark.slash" : "bookmark"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Remove Book", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
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
