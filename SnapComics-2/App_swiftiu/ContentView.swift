/*import SwiftUI
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
        ZStack {
            // Background
            Image("Wallpaper")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        Spacer()

Image(systemName: "eye.fill")
           .font(.system(size: 70))
           .foregroundColor(.white)
           .padding()
           .gesture(
               DragGesture(minimumDistance: 0, coordinateSpace: .local)
                   .onChanged { gesture in
                      
                       guard gesture.translation.width > 0 else { return }
                       let completion = min(1, Double(gesture.translation.width / UIScreen.main.bounds.width))
                       let cameraThreshold: Double = 0.2
                       if completion > cameraThreshold {
                           openCamera()
                       }
                   }
           )

       Spacer()
   }
)
            
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
          /*  Text(scannedText1)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.black.opacity(0.7))
                        .padding(.horizontal)
                )
                .offset(y: -50)*/

           
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
              
            }
            }
        }
        .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
            ImagePicker(sourceType: .camera, selectedImage: $capturedImage)
        }
    }
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("La fotocamera non è disponibile su questo dispositivo.")
            return
        }

        isImagePickerPresented.toggle() // Questo imposta a true la variabile che presenta il foglio
    }

    func loadImage() {
        performObjectDetection(on: capturedImage)
        performOCR(on: capturedImage)
    }

    func performObjectDetection(on image: UIImage) {
        guard let model = try? VNCoreMLModel(for: ml3().model) else {
            print("Errore durante il caricamento del modello di Object Detection.")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }

            detectedObjects.removeAll()

            for result in results {
                let objectName = result.labels.first?.identifier ?? "Unknown"
                detectedObjects.append(objectName)
                characterDetected = objectName
               
            }
        }

        let handler = VNImageRequestHandler(ciImage: CIImage(image: image)!)
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

       
        var localCharacterDetected: String?

       
        let handler = VNImageRequestHandler(ciImage: ciImage)
        let ocrRequest = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                if let unwrappedCharacterDetected = characterDetected {
                    speakText(unwrappedCharacterDetected)
                }

               if let unwrappedCharacterDetected = localCharacterDetected {
                    print ("ciao qua dovrebbe stare pippo")
                    speakText(unwrappedCharacterDetected)
                }
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
*/


/* SECONDO CODICE COMPLETO
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
        ZStack {
            // Background
            Image("Wallpaper")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Bottone per accedere alla fotocamera
                Button(action: {
                    openCamera()
                }) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .foregroundColor(Color.black.opacity(0.7))
                        )
                }
                .padding()

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
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("La fotocamera non è disponibile su questo dispositivo.")
            return
        }

        isImagePickerPresented.toggle() // Questo imposta a true la variabile che presenta il foglio
    }

    func loadImage() {
        performObjectDetection(on: capturedImage)
        performOCR(on: capturedImage)
    }

    func performObjectDetection(on image: UIImage) {
        // Rimuoviamo la configurazione aggiuntiva e usiamo l'inizializzatore appropriato
        guard let model = try? VNCoreMLModel(for: ml3().model) else {
            print("Errore durante il caricamento del modello di Object Detection.")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }

            detectedObjects.removeAll()

            for result in results {
                let objectName = result.labels.first?.identifier ?? "Unknown"
                detectedObjects.append(objectName)
                characterDetected = objectName
            }
        }

        let handler = VNImageRequestHandler(ciImage: CIImage(image: image)!)
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

                if let unwrappedCharacterDetected = characterDetected {
                    speakText(unwrappedCharacterDetected)
                }

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
 FINE SECONDO CODICE
*/

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
                                        .foregroundColor(Color.black.opacity(0.7))
                                )
                            Text("Library")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .position(x: (UIScreen.main.bounds.width / 2) + 15 , y: 150) //
 // Posiziona il bottone al centro orizzontalmente, 150 punti dal bordo superiore

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
                                        .foregroundColor(Color.black.opacity(0.7))
                                )
                            Text("Camera")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .position(x: (UIScreen.main.bounds.width / 2)+15, y: 30)// Posiziona il bottone al centro orizzontalmente, 300 punti dal bordo superiore

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
        performOCR(on: capturedImage)
    }

    func performObjectDetection(on image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Impossibile convertire l'immagine.")
            return
        }

        guard let model = try? VNCoreMLModel(for: MIC().model) else {
            print("Errore durante il caricamento del modello di Object Detection.")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }

            DispatchQueue.main.async {
                detectedObjects.removeAll()

                for result in results {
                    if let objectName = result.labels.first?.identifier {
                        detectedObjects.append(objectName)
                        characterDetected = objectName
                    }
                }
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

                if let unwrappedCharacterDetected = characterDetected {
                    speakText(unwrappedCharacterDetected)
                }

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
