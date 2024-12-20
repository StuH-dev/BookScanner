import SwiftUI

struct CollectionsView: View {
    @ObservedObject var library: Library
    @State private var newCollectionName: String = ""
    @State private var showingAddCollection = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground(colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(library.getCollections()).sorted(), id: \.self) { collection in
                        NavigationLink(destination: CollectionDetailView(library: library, collection: collection)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(collection)
                                        .font(.headline)
                                        .foregroundColor(ColorTheme.textPrimary)
                                    
                                    Text("\(library.getBooksInCollection(collection).count) books")
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(ColorTheme.textSecondary)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding()
                            .background(Color.adaptiveSurface(colorScheme))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Collections")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCollection = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(ColorTheme.primary)
                }
            }
        }
        .alert("Add Collection", isPresented: $showingAddCollection) {
            TextField("Collection Name", text: $newCollectionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Cancel", role: .cancel) {
                newCollectionName = ""
            }
            
            Button("Add") {
                if !newCollectionName.isEmpty {
                    library.addCollection(newCollectionName)
                    newCollectionName = ""
                }
            }
            .foregroundColor(ColorTheme.primary)
        } message: {
            Text("Enter a name for your new collection")
                .foregroundColor(ColorTheme.textPrimary)
        }
    }
    
    private func deleteCollections(at offsets: IndexSet) {
        let collectionsToDelete = offsets.map { Array(library.getCollections()).sorted()[$0] }
        for collection in collectionsToDelete {
            library.removeCollection(collection)
        }
    }
}

#Preview {
    NavigationView {
        CollectionsView(library: Library())
    }
}
