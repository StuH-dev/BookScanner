import SwiftUI

struct CollectionsView: View {
    @ObservedObject var library: Library
    @State private var newCollectionName: String = ""
    @State private var showingAddCollection = false
    @State private var showingRenameCollection = false
    @State private var selectedCollection: String? = nil
    @State private var renameText: String = ""
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
                        .contextMenu {
                            Button {
                                selectedCollection = collection
                                renameText = collection
                                showingRenameCollection = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                library.removeCollection(collection)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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
                        .imageScale(.large)
                        .foregroundColor(ColorTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddCollection) {
            NavigationView {
                Form {
                    Section {
                        TextField("Collection Name", text: $newCollectionName)
                    }
                }
                .navigationTitle("New Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            newCollectionName = ""
                            showingAddCollection = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            if !newCollectionName.isEmpty {
                                library.addCollection(newCollectionName)
                                newCollectionName = ""
                                showingAddCollection = false
                            }
                        }
                        .disabled(newCollectionName.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRenameCollection) {
            NavigationView {
                Form {
                    Section {
                        TextField("Collection Name", text: $renameText)
                    }
                }
                .navigationTitle("Rename Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            renameText = ""
                            selectedCollection = nil
                            showingRenameCollection = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Rename") {
                            if let collection = selectedCollection, !renameText.isEmpty {
                                library.renameCollection(from: collection, to: renameText)
                                renameText = ""
                                selectedCollection = nil
                                showingRenameCollection = false
                            }
                        }
                        .disabled(renameText.isEmpty || renameText == selectedCollection)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CollectionsView(library: Library())
    }
}
