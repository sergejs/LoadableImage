//
//  ImageView.swift
//
//
//  Created by Sergejs Smirnovs on 09.11.21.
//

import Cache
import HTTPClient
import ServiceContainer
import SwiftUI

public struct ImageView: View {
    @ObservedObject
    var imageLoader: ImageLoader
    @State
    var image = UIImage()
    let contentMode: ContentMode

    public init(
        withURL url: String,
        contentMode: ContentMode = .fill,
        httpClient: HTTPClientRequestDispatcher = InjectedValues[\.httpClient],
        cache: ImageCache = InjectedValues[\.imageCache]
    ) {
        self.contentMode = contentMode
        imageLoader = ImageLoader(
            urlString: url,
            httpClient: httpClient,
            cache: cache
        )
    }

    // MARK: Public

    public var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .onReceive(imageLoader.didChange) { image in
                self.image = image
            }
            .onAppear {
                Task {
                    await imageLoader.onAppear()
                }
            }
    }
}
