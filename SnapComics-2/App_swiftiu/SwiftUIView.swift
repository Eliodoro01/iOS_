import SwiftUI

struct LibraryView: View {
    @State private var albums: [Album] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isPhotoPickerPresented = false
    @State private var isImageViewPresented = false

    var body: some View {
            List {
                Section(header:
                            Text("Reading Now")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, -20)
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 0)
                            .padding(.bottom, 30)
                            .padding(.leading, -15)

                        HStack(spacing: -10) {
                            // Box sinistra
                            VStack(alignment: .leading, spacing: 10) {
                                Button(action: {
                                    isImageViewPresented.toggle()
                                }) {
                                    if let image = selectedImages.first {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 220)
                                            .cornerRadius(10)
                                            
                                    } else {
                                        Image("Soggetto")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 180, height: 240)
                                            
                                            .padding(.leading, 60)

                                    }
                                }
                                .padding(.top, 5)
                                .padding(.leading, -50)
                                Text("'Il regalo su misura'")
                                    .font(.custom("menlo", size: 22))
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .padding(.top, 5)
                                    .padding(.bottom, 50)
                                    .padding(.leading, 20)
                                    .fontWeight(.bold)
                            
                                Text("anno:2007")
                                    .font(.custom("menlo", size: 16))
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .padding(.top, -50)
                                    .padding(.bottom, 10)
                                    .padding(.leading, 30)
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, -30) // Riduce il padding verticale della sezione "Reading Now"
                    }
                    .padding(.horizontal, 10)
                }
                Section(header:
                            Text("Ready to Read")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, -20)
                ) {
                    ForEach(albums) { album in
                        if !album.images.isEmpty {
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
                                                Text("Album \(album.formattedCreationDateTime.prefix(19))") // Mostra solo i primi 19 caratteri (data e ora)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .padding(5)
                                                    .background(Color.black.opacity(0.7))
                                                    .cornerRadius(10),
                                                alignment: .bottomLeading
                                            )
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        Album.deleteAlbum(with: album.id)
                                        albums.removeAll { $0.id == album.id }
                                    }) {
                                        Label("Delete Album", systemImage: "trash")
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10) // Riduce il padding orizzontale intorno a ciascun album
                        }
                    }

                    Button(action: {
                        isPhotoPickerPresented.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Photos")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hue: 240/360, saturation: 0.75, brightness: 0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .sheet(isPresented: $isPhotoPickerPresented, onDismiss: createNewAlbum) {
                PhotoPicker(selectedImages: $selectedImages)
            }
            .onAppear(perform: loadAlbums)
            .background(
                NavigationLink(destination: ImageView(), isActive: $isImageViewPresented) {
                    EmptyView()
                }
            )
        
    }

    private func createNewAlbum() {
        guard !selectedImages.isEmpty else { return }
        let newAlbum = Album(images: selectedImages)
        Album.salvaAlbum(newAlbum)
        albums.append(newAlbum)
        selectedImages.removeAll()
    }

    private func loadAlbums() {
        albums = Album.caricaAlbum()
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
