//
//  MemoAddReactorTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
import RxSwift
@testable import MapbeDiary

final class MemoAddReactorTests: XCTestCase {
    private final class TestSharedEventService: SharedEventProtocol {
        let event = PublishSubject<SharedEvent>()
        func send(_ event: SharedEvent) {
            self.event.onNext(event)
        }
    }

    func test_reduce_setTitlePlaceHolder_setsKakaoPlaceholder() {
        let service = TestSharedEventService()
        let reactor = MemoAddReactor(sharedService: service)
        let next = reactor.reduce(
            state: MemoAddReactor.State(),
            mutation: .setTitlePlaceHolder("Road Address")
        )

        XCTAssertEqual(next.titlePlacHolder, "Road Address")
        XCTAssertEqual(next.kakaoPlaceHolder, "Road Address")
    }

    func test_reduce_setLocation_updatesCoordinates() {
        let service = TestSharedEventService()
        let reactor = MemoAddReactor(sharedService: service)
        let next = reactor.reduce(
            state: MemoAddReactor.State(),
            mutation: .setLocation(lat: "37.0", lon: "127.0")
        )

        XCTAssertEqual(next.lat, "37.0")
        XCTAssertEqual(next.lon, "127.0")
    }

    func test_reduce_setDismissTrigger_updatesFlag() {
        let service = TestSharedEventService()
        let reactor = MemoAddReactor(sharedService: service)
        let next = reactor.reduce(
            state: MemoAddReactor.State(),
            mutation: .setDismissTrigger(true)
        )

        XCTAssertTrue(next.dismissTrigger)
    }
}
