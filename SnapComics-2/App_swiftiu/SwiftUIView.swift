//
//  SwiftUIView.swift
//  App_swiftiu
//
//  Created by Giuseppe Cristiano on 24/06/24.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Benvenuto nella Libreria")
                    .font(.largeTitle)
                    .padding()
                // Puoi aggiungere qui la tua logica e componenti per mostrare le immagini dalla libreria
            }
            .navigationTitle("Libreria")
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

