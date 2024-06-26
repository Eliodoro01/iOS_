//
//  AlbumView.swift
//  App_swiftiu
//
//  Created by Eliodoro Mascolo on 26/06/24.
//

import Foundation
import SwiftUI

struct AlbumView: View {
    let album: Album

    var body: some View {
        ScrollView {
            VStack {
                ForEach(album.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .navigationTitle("Album \(album.id.uuidString.prefix(4))")
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImages = [
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo.fill")!
        ]
        let sampleAlbum = Album(images: sampleImages)
        AlbumView(album: sampleAlbum)
    }
}
