import SwiftUI
import AVFoundation
import Vision

struct AlbumView: View {
    let album: Album
    @State private var isShowingConfirmationAlert = false
    @Environment(\.presentationMode) var presentationMode

    let synthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var currentUtterance: AVSpeechUtterance?
    @State private var shouldResumeSpeech = false
    @State private var currentIndex: Int = 0 // Indice dell'immagine corrente
    @State private var currentIndexVisible: Int? // Indice dell'immagine corrente visibile

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
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
                                .id(-1) // ID unico per la cover image
                        }

                        ForEach(album.images.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                let image = album.images[index]
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                                    .onTapGesture {
                                        let text = recognizeText(from: image)
                                        speakText(text, atIndex: index)
                                    }
                                    .opacity(index == currentIndex ? 1.0 : 0.6) // Opacità immagine corrente
                                    .id(index)
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear
                                                .onAppear {
                                                    if currentIndexVisible == nil {
                                                        currentIndexVisible = currentIndex
                                                        scrollToCurrentImage(scrollViewProxy: scrollViewProxy, index: currentIndex)
                                                    }
                                                }
                                                .onChange(of: currentIndex) { newIndex in
                                                    currentIndexVisible = newIndex
                                                    scrollToCurrentImage(scrollViewProxy: scrollViewProxy, index: newIndex)
                                                }
                                        }
                                    )
                            }
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
            }

            HStack(spacing: 20) {
                Button(action: {
                    previousImage()
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 1)
                        )
                }

                Button(action: {
                    toggleSpeech()
                }) {
                    Image(systemName: isSpeaking ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 2)
                        )
                }

                Button(action: {
                    repeatContent()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 2)
                        )
                }

                Button(action: {
                    nextImage()
                }) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 2)
                        )
                }
            }
            .padding()
        }
        .navigationTitle("Album \(album.formattedCreationDateTime.prefix(16))")
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

    private func recognizeText(from image: UIImage) -> String {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to convert image to CIImage.")
            return ""
        }

        var recognizedText = ""

        let handler = VNImageRequestHandler(ciImage: ciImage)
        let ocrRequest = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                recognizedText = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
            }
        }

        do {
            try handler.perform([ocrRequest])
        } catch {
            print("Error performing OCR request: \(error)")
        }

        return recognizedText
    }

    private func speakText(_ text: String, atIndex index: Int) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.25
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")

        if shouldResumeSpeech {
            synthesizer.continueSpeaking()
        } else {
            synthesizer.stopSpeaking(at: .immediate)
            synthesizer.speak(utterance)
            currentUtterance = utterance
            isSpeaking = true
        }

        shouldResumeSpeech = false
        currentIndex = index
    }

    private func toggleSpeech() {
        if isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            if currentUtterance == nil {
                if let firstImage = album.images.first {
                    let text = recognizeText(from: firstImage)
                    speakText(text, atIndex: 0)
                }
            } else {
                synthesizer.continueSpeaking()
                isSpeaking = true
            }
        }
    }

    private func repeatContent() {
        if let currentImage = album.images[safe: currentIndex] {
            let text = recognizeText(from: currentImage)
            speakText(text, atIndex: currentIndex)
        }
    }

    private func previousImage() {
        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = album.images.count - 1
        }
        
        // Speak the text of the new current image if speech is active
        if isSpeaking {
            let text = recognizeText(from: album.images[currentIndex])
            speakText(text, atIndex: currentIndex)
        }
    }

    private func nextImage() {
        currentIndex += 1
        if currentIndex >= album.images.count {
            currentIndex = 0
        }
        
        // Speak the text of the new current image if speech is active
        if isSpeaking {
            let text = recognizeText(from: album.images[currentIndex])
            speakText(text, atIndex: currentIndex)
        }
    }

    private func scrollToCurrentImage(scrollViewProxy: ScrollViewProxy, index: Int) {
        guard let currentIndexVisible = currentIndexVisible else { return }
        
        withAnimation {
            scrollViewProxy.scrollTo(currentIndexVisible, anchor: .center)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
