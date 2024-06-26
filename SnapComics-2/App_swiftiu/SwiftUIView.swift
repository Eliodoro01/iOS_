//
//  SwiftUIView.swift
//  App_swiftiu
//
//  Created by Giuseppe Cristiano on 24/06/24.
//

/*i mport SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Benvenuto nella Libreria")
                    .font(.largeTitle)
                    .padding()
                // Puoi aggiungere qui la tua logica e componenti per mostrare le immagini dalla libreria
            }
            .navigationTitle("Reading Now")
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
} */
import SwiftUI

struct Album: Identifiable {
    let id = UUID()
    var images: [UIImage]
    var coverImage: UIImage? {
        images.first
    }
}

struct LibraryView: View {
    @State private var albums: [Album] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isPhotoPickerPresented = false
    @State private var selectedAlbum: Album?

    var body: some View {
        NavigationView {
            VStack {
                Text("Current")
                    .font(.largeTitle)
                    .padding()

                // Visualizza gli album
                ScrollView {
                    ForEach(albums) { album in
                        VStack {
                            if let coverImage = album.coverImage {
                                NavigationLink(destination: AlbumView(album: album)) {
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
                    }
                }

                Spacer()
            }
            .navigationTitle("Reading Now")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPhotoPickerPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPhotoPickerPresented, onDismiss: createNewAlbum) {
                PhotoPicker(selectedImages: $selectedImages)
            }
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
