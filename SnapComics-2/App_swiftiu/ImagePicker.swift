//
//  ImagePicker.swift
//  App_swiftiu
//
//  Created by francescomaria on 18/12/23.
//

import SwiftUI
import UIKit
import SwiftUI
import AVFoundation


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    
    // Cambiare il valore da .photoLibrary a .camera se si
    // vuole scattare una nuova foto
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    let synthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var currentUtterance: AVSpeechUtterance?
    @State private var shouldResumeSpeech = false
    @State private var playbackPosition: Int = 0 // Traccia la posizione di riproduzione
    @State private var currentIndex: Int = 0 // Indice dell'immagine corrente


    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

