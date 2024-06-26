import SwiftUI

// Definizione della struttura Album
struct Album: Identifiable {
    let id = UUID()
    var images: [UIImage]
    var coverImage: UIImage? {
        images.first
    }
}

// Definizione della vista principale LibraryView
struct LibraryView: View {
    @State private var albums: [Album] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isPhotoPickerPresented = false

    var body: some View {
        List {
            // Sezione Reading Now con titolo e immagini Paperino e Topolino
            Section(header:
                        Text("Reading Now")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                    HStack(spacing: 20) {
                        // Box sinistra con Paperino
                        VStack(alignment: .leading, spacing: 10) {
                            if let image = selectedImages.first {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
                            } else {
                                Image("PAPERINO") // Utilizza l'immagine dall'asset chiamata "PAPERINO"
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
                            }
                            Text("Paperino")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(.top, 5)
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal)

                        // Box destra con Topolino
                        VStack(alignment: .leading, spacing: 10) {
                            if let image = selectedImages.last {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
                            } else {
                                Image("topolino") // Utilizza l'immagine dall'asset chiamata "TOPOLINO"
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(10)
                            }
                            Text("Topolino")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(.top, 5)
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }

            // Sezione dei fumetti da leggere
            Section(header:
                        Text("Ready to Read")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
            ) {
                ForEach(albums) { album in
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: AlbumView(album: album)) {
                            if let coverImage = album.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .padding(.vertical, 5)
                                    .overlay(
                                        Text("Album \(album.id.uuidString.prefix(4))")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(10),
                                        alignment: .bottomLeading
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                }

                // Bottone per aggiungere foto centrato
                Button(action: {
                    isPhotoPickerPresented.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Photos")
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Library")
        .sheet(isPresented: $isPhotoPickerPresented, onDismiss: createNewAlbum) {
            PhotoPicker(selectedImages: $selectedImages)
        }
    }

    private func createNewAlbum() {
        guard !selectedImages.isEmpty else { return }
        albums.append(Album(images: selectedImages))
        selectedImages.removeAll()
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
