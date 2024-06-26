import SwiftUI

struct AlbumView: View {
    let album: Album

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Visualizzazione dell'immagine di copertina
                if let coverImage = album.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill per mantenere le proporzioni e riempire lo spazio
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .clipped() // Clipped per assicurarsi che l'immagine non esca dal frame
                }
                
                // Visualizzazione delle immagini dell'album
                ForEach(album.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill per mantenere le proporzioni e riempire lo spazio
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
            }
            .padding()
        }
        .navigationTitle("Album \(album.id.uuidString.prefix(4))")
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImages = [
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo.fill")!
        ]
        let sampleAlbum = Album(images: sampleImages)
        return AlbumView(album: sampleAlbum)
    }
}
