import SwiftUI

struct AlbumView: View {
    let album: Album
    @State private var isShowingConfirmationAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                if let coverImage = album.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .clipped()
                }

                ForEach(album.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }

                Text("Created on: \(album.formattedCreationDateTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Album \(album.formattedCreationDateTime.prefix(16))") // Mostra solo i primi 16 caratteri (data e ora)
        .navigationBarItems(trailing:
            Button(action: {
                isShowingConfirmationAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        )
        .alert(isPresented: $isShowingConfirmationAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this album?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAlbum()
                },
                secondaryButton: .cancel()
            )
        }
        .listRowInsets(EdgeInsets())
    }

    private func deleteAlbum() {
        Album.deleteAlbum(with: album.id)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImages = [
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo.fill")!
        ]
        let sampleAlbum = Album(id: UUID(), images: sampleImages, creationDate: Date())
        return AlbumView(album: sampleAlbum)
    }
}
