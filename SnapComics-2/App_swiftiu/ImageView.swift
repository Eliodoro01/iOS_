import SwiftUI

struct ImageView: View {
    @State private var images: [UIImage] = []
   
    
    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    Text("Nessuna immagine trovata")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(images.indices, id: \.self) { index in
                                Image(uiImage: images[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                    }
                }

                HStack {
                    Button(action: {
                        // Azione del primo pulsante
                    }) {
                        Text("Pulsante 1")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        // Azione del secondo pulsante
                    }) {
                        Text("Pulsante 2")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        // Azione del terzo pulsante
                    }) {
                        Text("Pulsante 3")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        // Azione del quarto pulsante
                    }) {
                        Text("Pulsante 4")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Image View")
            .navigationBarItems(leading: Button(action: {
              
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            })
            .onAppear(perform: loadImages)
        }
    }

    private func loadImages() {
        guard let folderURL = Bundle.main.resourceURL?.appendingPathComponent("PreloadedImages") else {
            print("Cartella PreloadedImages non trovata.")
            return
        }
        
        do {
            let fileManager = FileManager.default
            let imagePaths = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            
            images = imagePaths.compactMap { path in
                if path.pathExtension.lowercased() == "jpg" {
                    if let image = UIImage(contentsOfFile: path.path) {
                        return resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
                    }
                }
                return nil
            }
        } catch {
            print("Errore nel caricamento delle immagini: \(error)")
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine what scale factor to use to adjust the image size.
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // Create a graphics context and draw the image into it.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        
        // Get the new image from the context.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
