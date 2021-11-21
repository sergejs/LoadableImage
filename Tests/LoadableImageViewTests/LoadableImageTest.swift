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

    func testBasicLoading() async {
        let data = UIImage(systemName: "square.and.arrow.up")!.pngData()!
        let image = UIImage(data: data)!
        let placeholder = AnyView(Text("plaholder"))

        let loadingExpectation = expectation(description: "Loading")
        let loadedExpectation = expectation(description: "Loaded")

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
            placeholderView: placeholder,
            httpClient: mockHttp,
            cache: cache
        )

        var recevedState: ImageLoader.State?
        sut.didChange
            .filter {
                if case .loading = $0 {
                    return true
                }
                return false
            }
            .first()
            .sink(
                receiveCompletion: { completion in
                    loadingExpectation.fulfill()
                }, receiveValue: { state in
                    if case let .loading(view) = state {
                        XCTAssertNotNil(view)
                    } else {
                        XCTFail("Unexpected result")
                    }
                }
            )
            .store(in: &disposeBag)

        sut.didChange
            .filter {
                if case .loaded = $0 {
                    return true
                }
                return false
            }
            .first()
            .sink(
                receiveCompletion: { completion in
                    loadedExpectation.fulfill()
                }, receiveValue: { state in
                    recevedState = state
                    if case let .loaded(image) = state {
                        XCTAssertNotNil(image)
                    } else {
                        XCTFail("Unexpected result")
                    }
                }
            )
            .store(in: &disposeBag)

        sut.onAppear()
        await waitForExpectations(timeout: 5)

        if case let .loaded(newImage) = recevedState {
            XCTAssertEqual(newImage.size, image.size)
        } else {
            XCTFail("Unexpected result")
        }
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
        var recevedState: ImageLoader.State?

        sut.didChange
            .filter {
                if case .loaded = $0 {
                    return true
                }
                return false
            }
            .first()
            .sink(
                receiveCompletion: { completion in
                    expectation.fulfill()
                }, receiveValue: { state in
                    recevedState = state
                    if case let .loaded(image) = state {
                        XCTAssertNotNil(image)
                    } else {
                        XCTFail("Unexpected result")
                    }
                }
            )
            .store(in: &disposeBag)

        sut.onAppear()

        await waitForExpectations(timeout: 5)

        if case let .loaded(newImage) = recevedState {
            XCTAssertEqual(newImage.size, image.size)
        } else {
            XCTFail("Unexpected result")
        }
    }
}
