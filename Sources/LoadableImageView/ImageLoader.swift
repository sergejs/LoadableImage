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

public typealias ImageCache = Cache<String, UIImage>

public final class ImageLoader: ObservableObject {
    // MARK: Lifecycle

    public init(
        urlString: String,
        httpClient: HTTPClientRequestDispatcher,
        cache: ImageCache
    ) {
        self.cache = cache
        self.httpClient = httpClient
        self.urlString = urlString
    }

    // MARK: Public

    public var didChange = PassthroughSubject<UIImage, Never>()

    public func onAppear() {
        Task {
            await loadImage()
        }
    }

    private func loadImage() async {
        if let cachedImage = cache.value(forKey: urlString) {
            update(
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
            update(
                image: image,
                forUrl: urlString
            )
        }
    }

    // MARK: Internal

    var image = UIImage() {
        didSet {
            didChange.send(image)
        }
    }

    // MARK: Private

    private let httpClient: HTTPClientRequestDispatcher
    private let cache: ImageCache
    private let urlString: String

    private func update(
        image: UIImage,
        forUrl urlString: String
    ) {
        cache.insert(image, forKey: urlString)

        DispatchQueue.main.async { [weak self] in
            self?.image = image
        }
    }
}
