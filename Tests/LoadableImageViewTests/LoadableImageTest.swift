//
//  LoadableImageTest.swift
//
//
//  Created by Sergejs Smirnovs on 09.11.21.
//

import Cache
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

    func testBasicUsage() async {
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

        let didChangeSubject = sut.didChange

        didChangeSubject
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &disposeBag)

        await sut.onAppear()
        wait(for: [expectation], timeout: 10)
        let newImage = sut.image
        XCTAssertEqual(newImage.size, image.size)
    }

    func testCache() async {
        let data = UIImage(systemName: "square.and.arrow.up")!.pngData()!
        let image = UIImage(data: data)!

        let expectation = expectation(description: "Loading")
        await cache.insert(image, forKey: "url-string")

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

        let didChangeSubject = sut.didChange

        didChangeSubject
            .sink { newImage in
                expectation.fulfill()
                XCTAssertEqual(newImage.size, image.size)
            }
            .store(in: &disposeBag)

        await sut.onAppear()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(sut.image.size, image.size)
    }
}
