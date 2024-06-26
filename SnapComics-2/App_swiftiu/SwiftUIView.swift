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

struct LibraryView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var isPhotoPickerPresented = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Current")
                    .font(.largeTitle)
                    .padding()

                // Visualizza le immagini selezionate
                ScrollView {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.vertical, 5)
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
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPicker(selectedImages: $selectedImages)
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
