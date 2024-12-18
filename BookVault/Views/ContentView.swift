import SwiftUI

struct ContentView: View {
    @StateObject private var library = Library()
    @State private var viewMode: ViewMode = .grid
    @State private var showingScanner = false
    @State private var showingAuthorSearch = false
    @State private var showingLentBooks = false
    @State private var isDarkMode = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var searchText = ""
    @State private var selectedGenre: String?
    @State private var authorFilter = ""
    @State private var selectedTab = 0
    
    var availableGenres: [String] {
        Array(Set(library.books.flatMap { $0.genres })).sorted()
    }
    
    var body: some View {
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
                            }
                            
                            Button(action: {
                                showingAuthorSearch.toggle()
                            }) {
                                Label("Search by Author", systemImage: "magnifyingglass")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                viewMode = viewMode == .grid ? .list : .grid
                            }) {
                                Label(
                                    viewMode == .grid ? "List View" : "Grid View",
                                    systemImage: viewMode == .grid ? "list.bullet" : "square.grid.2x2"
                                )
                            }
                            
                            Button(action: {
                                isDarkMode.toggle()
                            }) {
                                Label(
                                    isDarkMode ? "Light Mode" : "Dark Mode",
                                    systemImage: isDarkMode ? "sun.max" : "moon"
                                )
                            }
                            
                            Divider()
                            
                            Button(action: {
                                showingBackupAlert = true
                            }) {
                                Label("Backup Library", systemImage: "arrow.up.doc")
                            }
                            
                            Button(action: {
                                showingRestoreAlert = true
                            }) {
                                Label("Restore Library", systemImage: "arrow.down.doc")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .tabItem {
                Label("Books", systemImage: "book")
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
                BarcodeScannerView(library: library)
            }
            .tabItem {
                Label("Scan", systemImage: "barcode.viewfinder")
            }
            .tag(2)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
        }
        .alert("Restore Library", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                library.restoreFromBackup()
            }
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
