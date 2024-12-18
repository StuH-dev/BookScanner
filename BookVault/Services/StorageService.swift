import Foundation

enum StorageError: LocalizedError {
    case saveFailed
    case loadFailed
    case backupFailed
    case restoreFailed
    case migrationFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save library data"
        case .loadFailed:
            return "Failed to load library data"
        case .backupFailed:
            return "Failed to create backup"
        case .restoreFailed:
            return "Failed to restore from backup"
        case .migrationFailed:
            return "Failed to migrate data"
        }
    }
}

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    
    // Current data version - increment this when making breaking changes to data model
    private let currentDataVersion = 1
    private let versionKey = "LibraryDataVersion"
    private let backupKey = "LibraryBackup"
    
    private init() {}
    
    func save(_ books: [Book], forKey key: String) throws {
        do {
            let encoded = try JSONEncoder().encode(books)
            userDefaults.set(encoded, forKey: key)
            userDefaults.set(currentDataVersion, forKey: versionKey)
        } catch {
            print("Storage Error: Failed to save books - \(error.localizedDescription)")
            throw StorageError.saveFailed
        }
    }
    
    func load(forKey key: String) throws -> [Book] {
        do {
            // Check if data needs migration
            let dataVersion = userDefaults.integer(forKey: versionKey)
            if dataVersion < currentDataVersion {
                try migrateData(fromVersion: dataVersion)
            }
            
            guard let data = userDefaults.data(forKey: key) else {
                return []
            }
            
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("Storage Error: Failed to load books - \(error.localizedDescription)")
            throw StorageError.loadFailed
        }
    }
    
    func createBackup(books: [Book]) throws {
        do {
            let encoded = try JSONEncoder().encode(books)
            userDefaults.set(encoded, forKey: backupKey)
        } catch {
            print("Storage Error: Failed to create backup - \(error.localizedDescription)")
            throw StorageError.backupFailed
        }
    }
    
    func restoreFromBackup() throws -> [Book] {
        do {
            guard let data = userDefaults.data(forKey: backupKey) else {
                return []
            }
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("Storage Error: Failed to restore from backup - \(error.localizedDescription)")
            throw StorageError.restoreFailed
        }
    }
    
    private func migrateData(fromVersion: Int) throws {
        // Implement data migration logic here when needed
        // For example, if we add new properties to Book model in future versions
        
        // For now, just update the version number since we don't have any migrations yet
        userDefaults.set(currentDataVersion, forKey: versionKey)
    }
}
