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
    var state: ImageLoader.State = .none
    let contentMode: ContentMode

    public init(
        withURL url: String,
        contentMode: ContentMode = .fill,
        placeholderView: AnyView? = nil,
        failView: AnyView? = nil,
        httpClient: HTTPClientRequestDispatcher = InjectedValues[\.httpClient],
        cache: ImageCache = InjectedValues[\.imageCache]
    ) {
        self.contentMode = contentMode
        imageLoader = ImageLoader(
            urlString: url,
            placeholderView: placeholderView,
            failView: failView,
            httpClient: httpClient,
            cache: cache
        )
    }

    public var body: some View {
        VStack {
            imageView(state)
        }
        .onReceive(imageLoader.didChange) { state in
            self.state = state
        }
    }

    @ViewBuilder
    func imageView(_ state: ImageLoader.State) -> some View {
        switch state {
            case .none:
                EmptyView()
            case let .loading(view):
                view
            case let .loaded(image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case let .failed(view):
                view
        }
    }
}
