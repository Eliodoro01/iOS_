import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var isImagePickerPresented = false
    @State private var capturedImage: UIImage = UIImage()
    @State private var detectedObjects: [String] = []
    @State private var scannedText: String?
    @State private var characterDetected: String?
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Image("blu")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    
                VStack {
                    // Bottone per accedere alla libreria
                    NavigationLink(destination: LibraryView()) {
                        VStack {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Circle()
                                        .foregroundColor(Color(hue: 240/360, saturation: 0.95, brightness: 0.7))
                                )
                            Text("Library")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .position(x: (UIScreen.main.bounds.width / 2) + 25, y: 170) // Posiziona il bottone al centro orizzontalmente, 150 punti dal bordo superiore
                    }

                    // Bottone per accedere alla fotocamera
                    Button(action: {
                        openCamera()
                    }) {
                        VStack {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Circle()
                                        .foregroundColor(Color(hue: 240/360, saturation: 0.95, brightness: 0.7))
                                )
                            Text("Camera")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .position(x: (UIScreen.main.bounds.width / 2)+25, y: 15)// Posiziona il bottone al centro orizzontalmente, 300 punti dal bordo superiore

                    Spacer()
                }

                if scannedText != nil {
                    VStack {
                        if let characterDetected = characterDetected {
                            Text("\(characterDetected):")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.black.opacity(0.7))
                                        .padding(.horizontal)
                                )
                                .offset(y: -50)
                        }

                        // Visualizza il testo scannerizzato
                        Text(scannedText ?? "")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.black.opacity(0.7))
                                    .padding(.horizontal)
                            )
                            .offset(y: -50)

                        Button(action: {
                            // Torna indietro
                            scannedText = nil
                        }) {
                            Text("Back")
                                .foregroundColor(.white)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .padding(.top, 20)
                        }
                    }
                }

                if !detectedObjects.isEmpty {
                    VStack {
                        Spacer()
                        // Aggiungi qui i componenti per mostrare gli oggetti rilevati, se necessario
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                ImagePicker(sourceType: .camera, selectedImage: $capturedImage)
            }
        }
    }

    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("La fotocamera non è disponibile su questo dispositivo.")
            return
        }

        isImagePickerPresented = true
    }

    func loadImage() {
        performObjectDetection(on: capturedImage)
    }

    func performObjectDetection(on image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Impossibile convertire l'immagine.")
            return
        }

        let model: PIPPO_1 = {
            do {
                let config = MLModelConfiguration()
                return try PIPPO_1(configuration: config)
            } catch {
                print(error)
                fatalError("Couldn't create SleepCalculator")
            }
        }()
        
        
        guard let model = try? VNCoreMLModel(for: model.model) else {
            print("Errore durante il caricamento del modello di Object Detection.")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                print("Nessun risultato trovato nella richiesta di Object Detection.")
                return
            }

            DispatchQueue.main.async {
                detectedObjects.removeAll()

                for result in results {
                    if let objectName = result.labels.first?.identifier {
                        detectedObjects.append(objectName)
                        characterDetected = objectName

                        // Leggi il personaggio riconosciuto
                        if let unwrappedCharacterDetected = characterDetected {
                            speakText(unwrappedCharacterDetected)
                        }
                    }
                }

                // Una volta riconosciuto il personaggio, esegui OCR
                performOCR(on: image)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Errore durante l'esecuzione della richiesta di Object Detection: \(error)")
        }
    }

    func performOCR(on image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Impossibile convertire l'immagine.")
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        let ocrRequest = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                print(recognizedText)
                speakText(recognizedText)
            }
        }

        do {
            try handler.perform([ocrRequest])
        } catch {
            print("Errore durante l'esecuzione della richiesta di OCR: \(error)")
        }
    }

    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.50
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")

        synthesizer.speak(utterance)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
