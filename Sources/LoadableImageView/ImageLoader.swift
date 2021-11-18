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
    let didChange = PassthroughSubject<UIImage, Never>()

    var image = UIImage() {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(self.image)
            }
        }
    }

    private let httpClient: HTTPClientRequestDispatcher
    private let cache: ImageCache
    private let urlString: String

    init(
        urlString: String,
        httpClient: HTTPClientRequestDispatcher,
        cache: ImageCache
    ) {
        self.cache = cache
        self.httpClient = httpClient
        self.urlString = urlString
    }

    func onAppear() async {
        await loadImage()
    }

    private func loadImage() async {
        if let cachedImage = await cache.value(forKey: urlString) {
            await update(
                image: cachedImage,
                forUrl: urlString
            )
            return
        }

        guard
            let urlComponents = URLComponents(string: urlString)
        else {
            return
        }

        let request = HTTPRequest(urlComponents: urlComponents)
        let response = try? await httpClient.execute(request: request)
        if let data = response?.body, let image = UIImage(data: data) {
            await update(
                image: image,
                forUrl: urlString
            )
        }
    }

    private func update(
        image: UIImage,
        forUrl urlString: String
    ) async {
        self.image = image
        await cache.insert(image, forKey: urlString)
    }
}
