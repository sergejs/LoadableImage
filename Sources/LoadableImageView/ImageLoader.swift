//
//  ImageLoader.swift
//
//
//  Created by Sergejs Smirnovs on 09.11.21.
//

import Cache
import Combine
import HTTPClient
import SwiftUI

final class ImageLoader: ObservableObject {
    enum State {
        case none
        case loading(AnyView?)
        case loaded(UIImage)
        case failed(AnyView?)
    }

    let didChange = PassthroughSubject<State, Never>()

    private let httpClient: HTTPClientRequestDispatcher
    private let cache: ImageCache
    private let urlString: String
    private let placeholderView: AnyView?
    private let failView: AnyView?

    init(
        urlString: String,
        placeholderView: AnyView? = nil,
        failView: AnyView? = nil,
        httpClient: HTTPClientRequestDispatcher,
        cache: ImageCache
    ) {
        self.cache = cache
        self.httpClient = httpClient
        self.urlString = urlString
        self.placeholderView = placeholderView
        self.failView = failView
        update(with: .none)
    }

    func onAppear() {
        Task {
            await loadImage()
        }
    }

    private func loadImage() async {
        update(with: .loading(placeholderView))

        if let cachedImage = await cache.value(forKey: urlString) {
            update(with: .loaded(cachedImage))
            return
        }

        guard
            let urlComponents = URLComponents(string: urlString)
        else {
            update(with: .failed(failView))
            return
        }

        do {
            let request = HTTPRequest(urlComponents: urlComponents)
            let response = try await httpClient.execute(request: request)
            if let data = response.body, let image = UIImage(data: data) {
                update(with: .loaded(image))
                await cache.insert(image, forKey: urlString)
            } else {
                update(with: .failed(failView))
            }
        } catch {
            update(with: .failed(failView))
        }
    }

    private func update(with state: State) {
        didChange.send(state)
    }
}
