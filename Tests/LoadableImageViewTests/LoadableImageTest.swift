//
//  LoadableImageTest.swift
//
//
//  Created by Sergejs Smirnovs on 09.11.21.
//

import Combine
import HTTPClient
@testable import LoadableImageView
import SwiftUI
import UIKit
import XCTest

class LoadableImageTest: XCTestCase {
    var disposeBag = [AnyCancellable]()
    let mockHttp = MockHTTPClient()
    let cache = ImageCache()

    func testBasicUsage() {
        let data = UIImage(systemName: "square.and.arrow.up")!.pngData()!
        let image = UIImage(data: data)!

        let expectation = expectation(description: "Loading")

        mockHttp.then { request in
            let response = HTTPResponse(
                request: request,
                response: HTTPURLResponse(),
                body: data
            )

            return .success(response)
        }

        let sut = ImageLoader(
            urlString: "url-string",
            httpClient: mockHttp,
            cache: cache
        )
        sut.didChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &disposeBag)

        sut.onAppear()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(sut.image.size, image.size)
    }

    func testCache() {
        let data = UIImage(systemName: "square.and.arrow.up")!.pngData()!
        let image = UIImage(data: data)!

        let expectation = expectation(description: "Loading")
        cache.insert(image, forKey: "url-string")

        mockHttp.then { request in
            XCTFail("Unexpected http request")

            let response = HTTPResponse(
                request: request,
                response: HTTPURLResponse(),
                body: Data()
            )

            return .success(response)
        }

        let sut = ImageLoader(
            urlString: "url-string",
            httpClient: mockHttp,
            cache: cache
        )
        sut.didChange
            .sink { newImage in
                expectation.fulfill()
                XCTAssertEqual(newImage.size, image.size)
            }
            .store(in: &disposeBag)

        sut.onAppear()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(sut.image.size, image.size)
    }
}
