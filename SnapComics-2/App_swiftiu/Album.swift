import Foundation
import UIKit

struct Album: Identifiable {
    let id = UUID()
    var images: [UIImage]
    var coverImage: UIImage? {
        images.first
    }

    static func salvaImmagini(_ images: [UIImage]) {
        var imagePaths: [String] = []
        for image in images {
            let imageName = "\(UUID().uuidString).jpg"
            if let path = saveImage(image, withName: imageName) {
                imagePaths.append(path)
            }
        }
        UserDefaults.standard.set(imagePaths, forKey: "savedImages")
    }

    static func caricaImmagini() -> [UIImage] {
        guard let imagePaths = UserDefaults.standard.stringArray(forKey: "savedImages") else { return [] }
        return imagePaths.compactMap { loadImage(fromPath: $0) }
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
