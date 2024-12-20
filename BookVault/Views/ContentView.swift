import SwiftUI

struct ContentView: View {
    @StateObject private var library = Library()
    @State private var viewMode: ViewMode = .grid
    @State private var showingScanner = false
    @State private var showingAuthorSearch = false
    @State private var showingLentBooks = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var showingAbout = false
    @State private var searchText = ""
    @State private var selectedGenre: String?
    @State private var authorFilter = ""
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var availableGenres: [String] {
        Array(Set(library.books.flatMap { $0.genres })).sorted()
    }
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground(colorScheme)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationView {
                    BookListView(
                        library: library,
                        toggleRead: { id in
                            if let book = library.books.first(where: { $0.id == id }) {
                                library.toggleRead(book)
                            }
                        },
                        isRead: { id in
                            library.books.first(where: { $0.id == id })?.isRead ?? false
                        },
                        searchText: $searchText,
                        selectedGenre: $selectedGenre,
                        authorFilter: $authorFilter,
                        viewMode: $viewMode
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button(action: {
                                    showingScanner.toggle()
                                }) {
                                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                                
                                Button(action: {
                                    showingAuthorSearch.toggle()
                                }) {
                                    Label("Search by Author", systemImage: "magnifyingglass")
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    viewMode = viewMode == .grid ? .list : .grid
                                }) {
                                    Label(
                                        viewMode == .grid ? "Switch to List View" : "Switch to Grid View",
                                        systemImage: viewMode == .grid ? "list.bullet" : "square.grid.2x2"
                                    )
                                    .foregroundColor(ColorTheme.textPrimary)
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    showingBackupAlert = true
                                }) {
                                    Label("Backup Library", systemImage: "arrow.up.doc")
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                                
                                Button(action: {
                                    showingRestoreAlert = true
                                }) {
                                    Label("Restore Library", systemImage: "arrow.down.doc")
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(ColorTheme.primary)
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(0)
                
                NavigationView {
                    CollectionsView(library: library)
                }
                .tabItem {
                    Label("Collections", systemImage: "folder")
                }
                .tag(1)
                
                NavigationView {
                    AboutView()
                }
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
            }
            .accentColor(ColorTheme.primary)
        }
        .sheet(isPresented: $showingScanner) {
            BarcodeScannerView(library: library)
        }
        .sheet(isPresented: $showingAuthorSearch) {
            NavigationView {
                AuthorSearchView(library: library)
            }
        }
        .alert("Backup Library", isPresented: $showingBackupAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Backup") {
                library.createBackup()
            }
            .foregroundColor(ColorTheme.primary)
        } message: {
            Text("Create a backup of your library?")
        }
        .alert("Restore Library", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) {
                library.restoreFromBackup()
            }
        } message: {
            Text("This will replace your current library with the backup. Are you sure?")
        }
    }
}

enum ViewMode {
    case list
    case grid
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
