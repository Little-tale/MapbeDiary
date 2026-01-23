//
//  OnboardReactorTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class OnboardReactorTests: XCTestCase {
    func test_reduce_changeButtonAlpha_setsOnce() {
        let reactor = OnboardReactor(sharedEvent: SharedEventService())
        let initial = OnboardReactor.State()

        let first = reactor.reduce(state: initial, mutation: .changeButtonAlpha(1.0))
        XCTAssertEqual(first.buttonAlpha, 1.0)
        XCTAssertTrue(first.animated)

        let second = reactor.reduce(state: first, mutation: .changeButtonAlpha(0.0))
        XCTAssertEqual(second.buttonAlpha, 1.0)
        XCTAssertTrue(second.animated)
    }
}
