import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("BookVault")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
                Section(header: Text("Developer")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stuart Hedger")
                            .font(.headline)
                        
                        Text("iOS Developer")
                            .foregroundColor(.secondary)
                        
                        Text("Based in Sydney, Australia")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("About BookVault")) {
                    Text("BookVault is a personal library management app that helps you organize and track your book collection. Scan barcodes, manage reading status, and keep track of borrowed books.")
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Features")) {
                    Label("Barcode scanning", systemImage: "barcode.viewfinder")
                    Label("Reading progress tracking", systemImage: "book.closed")
                    Label("Lending management", systemImage: "person.2")
                    Label("Collections organization", systemImage: "folder")
                    Label("Book search", systemImage: "magnifyingglass")
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/stuarthedger")!) {
                        Label("GitHub Profile", systemImage: "link")
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("About")
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
    AboutView()
}
