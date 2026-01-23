//
//  SearchReactorTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class SearchReactorTests: XCTestCase {
    func test_reduce_resetPaged_resetsPagingState() {
        let reactor = SearchReactor()
        var state = SearchReactor.State()
        state.pagedObj.currentPage = 3
        state.pagedObj.isEnd = true

        let next = reactor.reduce(state: state, mutation: .resetPaged)

        XCTAssertEqual(next.pagedObj.currentPage, 1)
        XCTAssertEqual(next.pagedObj.callItemCount, 15)
        XCTAssertEqual(next.pagedObj.isEnd, false)
    }

    func test_reduce_searchResults_setsIsEmpty() {
        let reactor = SearchReactor()
        let empty = reactor.reduce(
            state: SearchReactor.State(),
            mutation: .searchResults(results: [], isAppend: false)
        )
        XCTAssertTrue(empty.isEmpty)

        let entity = PlaceDocumentEntity(
            phone: "123",
            placeName: "Cafe",
            roadAddressName: "Road",
            x: "1",
            y: "2",
            id: UUID()
        )

        let nonEmpty = reactor.reduce(
            state: SearchReactor.State(),
            mutation: .searchResults(results: [entity], isAppend: false)
        )
        XCTAssertFalse(nonEmpty.isEmpty)
        XCTAssertEqual(nonEmpty.searchResults.count, 1)
    }

    func test_reduce_setLoading_updatesState() {
        let reactor = SearchReactor()
        let next = reactor.reduce(state: SearchReactor.State(), mutation: .setLoading(true))
        XCTAssertTrue(next.isLoading)
    }

    func test_reduce_setCurrentText_updatesText() {
        let reactor = SearchReactor()
        let next = reactor.reduce(state: SearchReactor.State(), mutation: .setCurrentText("query"))
        XCTAssertEqual(next.currentText, "query")
    }
}
