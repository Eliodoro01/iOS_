import SwiftUI
import AVFoundation
import Vision

struct ImageView: View {
    @State private var images: [UIImage] = [] // Stato per memorizzare le immagini caricate
    @State private var currentIndex: Int = 0 // Indice dell'immagine corrente
    
    let synthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var currentUtterance: AVSpeechUtterance?
    @State private var shouldResumeSpeech = false

    var body: some View {
        VStack {
            if images.isEmpty {
                Text("Nessuna immagine trovata") // Messaggio di default se non ci sono immagini
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.vertical) { // ScrollView verticale per scorrere le immagini da sopra a sotto
                    LazyVStack(spacing: 20) {
                        ForEach(images.indices, id: \.self) { index in
                            ImageViewItem(image: images[index], isCurrent: index == currentIndex)
                                .onTapGesture {
                                    let text = recognizeText(from: images[index])
                                    speakText(text)
                                    currentIndex = index
                                }
                                .frame(maxWidth: .infinity) // Espande l'immagine alla larghezza massima disponibile
                        }
                    }
                    .padding()
                }
            }

            HStack {
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

                Spacer()

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

                Spacer()

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

                Spacer()

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
                            Circle().stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .padding()
        }
        .onAppear(perform: loadImages) // Caricamento delle immagini all'apparire della vista
    }

    // Funzione per caricare le immagini dalla cartella PreloadedImages
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

    // Funzione per ridimensionare un'immagine alla dimensione target
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determina il fattore di scala da utilizzare per ridimensionare l'immagine
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // Crea un contesto grafico e disegna l'immagine al suo interno
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))

        // Ottieni la nuova immagine dal contesto
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    // Funzione per riconoscere il testo in un'immagine utilizzando Vision Framework
    private func recognizeText(from image: UIImage) -> String {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to convert image to CIImage.")
            return ""
        }

        var recognizedText = ""

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:]) // Opzioni vuote per configurare la richiesta

        // Configurazione per specificare l'orientazione preferita
        let ocrRequest = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                // Ordina le osservazioni in base alla posizione y per mantenere l'ordine verticale corretto
                let sortedResults = results.sorted { $0.boundingBox.origin.y < $1.boundingBox.origin.y }
                recognizedText = sortedResults.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.reversed().joined(separator: "\n") // Inverte l'ordine delle righe riconosciute
            }
        }
        
        // Imposta l'orientazione preferita per la lettura da sinistra a destra
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.usesLanguageCorrection = true
        ocrRequest.recognitionLanguages = ["it-IT"]
        ocrRequest.customWords = ["Nessuna"]

        do {
            try handler.perform([ocrRequest])
        } catch {
            print("Error performing OCR request: \(error)")
        }

        return recognizedText
    }


    // Funzione per avviare o fermare la sintesi vocale del testo riconosciuto
    private func toggleSpeech() {
        if isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            if currentUtterance == nil {
                let text = recognizeText(from: images[currentIndex])
                speakText(text)
            } else {
                synthesizer.continueSpeaking()
                isSpeaking = true
            }
        }
    }

    // Funzione per ripetere il contenuto dell'immagine corrente dall'inizio
    private func repeatContent() {
        let text = recognizeText(from: images[currentIndex])
        
        // Se la sintesi vocale è in corso, la pausa immediatamente
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        speakText(text)
    }

    // Funzione per avviare la sintesi vocale con il testo fornito
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.25
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")

        // Se la sintesi vocale è in pausa e deve riprendere, continua
        if shouldResumeSpeech {
            synthesizer.continueSpeaking()
            shouldResumeSpeech = false // Resetta il flag
            isSpeaking = true
        } else {
            synthesizer.speak(utterance)
            isSpeaking = true
        }

        currentUtterance = utterance
    }

    // Funzione per passare all'immagine precedente
    private func previousImage() {
        // Stoppa la sintesi vocale se è in corso
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }

        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = images.count - 1
        }

        // Avvia la sintesi vocale con il testo dell'immagine corrente
        let text = recognizeText(from: images[currentIndex])
        speakText(text)
    }

    // Funzione per passare all'immagine successiva
    private func nextImage() {
        // Stoppa la sintesi vocale se è in corso
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }

        currentIndex += 1
        if currentIndex >= images.count {
            currentIndex = 0
        }

        // Avvia la sintesi vocale con il testo dell'immagine corrente
        let text = recognizeText(from: images[currentIndex])
        speakText(text)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}

// Vista dell'elemento ImageView
struct ImageViewItem: View {
    let image: UIImage
    let isCurrent: Bool

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .opacity(isCurrent ? 1.0 : 0.6) // Opacità immagine corrente
    }
}
