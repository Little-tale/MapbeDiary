//
//  URLsTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class URLsTests: XCTestCase {
    func test_termsAndConditionsURL() {
        let url = URLs.termsAndConditions.url
        XCTAssertEqual(
            url?.absoluteString,
            "https://uneven-lute-2a1.notion.site/882adb18a7f34e4a8f3cdb49426ab553?pvs=4"
        )
    }

    func test_customerSupportURL() {
        let url = URLs.customerSupport.url
        XCTAssertEqual(
            url?.absoluteString,
            "https://uneven-lute-2a1.notion.site/d669dbe68558430f95ac223da59dc3f9?pvs=4"
        )
    }
}
