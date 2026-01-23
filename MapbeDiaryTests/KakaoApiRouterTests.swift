//
//  KakaoApiRouterTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class KakaoApiRouterTests: XCTestCase {
    func test_keywordLocation_queryDefaults() {
        let router = KakaoApiRouter.keywordLocation(text: "coffee", page: 2)
        let query = queryDictionary(router.query)

        XCTAssertEqual(query["query"], "coffee")
        XCTAssertEqual(query["page"], "2")
        XCTAssertEqual(query["x"], "126.9778222")
        XCTAssertEqual(query["y"], "37.5664056")
        XCTAssertEqual(query["redius"], "100")
    }

    func test_coordinate_query() {
        let router = KakaoApiRouter.coordinate(x: "127.1", y: "37.5")
        let query = queryDictionary(router.query)

        XCTAssertEqual(query["x"], "127.1")
        XCTAssertEqual(query["y"], "37.5")
    }

    private func queryDictionary(_ items: [URLQueryItem]?) -> [String: String] {
        let items = items ?? []
        return Dictionary(uniqueKeysWithValues: items.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
    }
}
