import Foundation
import UIKit

struct Album: Identifiable {
    let id: UUID
    var images: [UIImage]
    let creationDate: Date

    var coverImage: UIImage? {
        images.first
    }

    // Metodo calcolato per ottenere la data e l'ora di creazione formattate
    var formattedCreationDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: creationDate)
    }

    init(images: [UIImage]) {
        self.id = UUID()
        self.images = images
        self.creationDate = Date()
    }

    init(id: UUID, images: [UIImage], creationDate: Date) {
        self.id = id
        self.images = images
        self.creationDate = creationDate
    }

    // Salva un album completo con un identificatore unico
    static func salvaAlbum(_ album: Album) {
        // Salva le immagini come file e salva i percorsi
        let imagePaths = album.images.compactMap { saveImage($0, withName: "\(album.id.uuidString)_\($0.hashValue).jpg") }
        let albumData = ["id": album.id.uuidString, "creationDate": album.creationDate, "imagePaths": imagePaths] as [String : Any]
        
        var savedAlbums = UserDefaults.standard.array(forKey: "savedAlbums") as? [[String: Any]] ?? []
        savedAlbums.append(albumData)
        UserDefaults.standard.set(savedAlbums, forKey: "savedAlbums")
    }

    // Carica tutti gli album salvati
    static func caricaAlbum() -> [Album] {
        guard let savedAlbums = UserDefaults.standard.array(forKey: "savedAlbums") as? [[String: Any]] else { return [] }
        
        return savedAlbums.compactMap { albumData in
            guard let idString = albumData["id"] as? String,
                  let uuid = UUID(uuidString: idString),
                  let creationDate = albumData["creationDate"] as? Date,
                  let imagePaths = albumData["imagePaths"] as? [String] else { return nil }
            
            let images = imagePaths.compactMap { loadImage(fromPath: $0) }
            return Album(id: uuid, images: images, creationDate: creationDate)
        }
    }

    // Elimina un album specifico dalla memoria e da UserDefaults
    static func deleteAlbum(with id: UUID) {
        var savedAlbums = UserDefaults.standard.array(forKey: "savedAlbums") as? [[String: Any]] ?? []
        
        savedAlbums.removeAll { albumData in
            guard let albumIdString = albumData["id"] as? String,
                  let albumUUID = UUID(uuidString: albumIdString) else { return false }
            
            return albumUUID == id
        }
        
        UserDefaults.standard.set(savedAlbums, forKey: "savedAlbums")
    }

    private static func saveImage(_ image: UIImage, withName name: String) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsDirectory.appendingPathComponent(name)
        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    private static func loadImage(fromPath path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
}
