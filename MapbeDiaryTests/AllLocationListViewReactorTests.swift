//
//  AllLocationListViewReactorTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
import RxSwift
@testable import MapbeDiary

final class AllLocationListViewReactorTests: XCTestCase {
    private final class TestSharedEventService: SharedEventProtocol {
        let event = PublishSubject<SharedEvent>()
        func send(_ event: SharedEvent) {
            self.event.onNext(event)
        }
    }

    func test_reduce_removedItem_removesLocationMemo() {
        let service = TestSharedEventService()
        let reactor = AllLocationListViewReactor(folderID: "folder", sharedService: service)
        let memo1 = LocationMemoEntity(
            id: "1",
            title: "A",
            location: nil,
            contents: nil,
            phoneNumber: nil,
            regDate: Date(),
            detailMemos: []
        )
        let memo2 = LocationMemoEntity(
            id: "2",
            title: "B",
            location: nil,
            contents: nil,
            phoneNumber: nil,
            regDate: Date(),
            detailMemos: []
        )
        let folder = FolderEntity(
            id: "folder",
            name: "Folder",
            regDate: Date(),
            modifyDate: Date(),
            index: 0,
            locationMemos: [memo1, memo2]
        )
        var state = AllLocationListViewReactor.State(folderID: "folder")
        state.item = folder

        let next = reactor.reduce(state: state, mutation: .removedItem(index: 0))

        XCTAssertEqual(next.item?.locationMemos.count, 1)
        XCTAssertEqual(next.item?.locationMemos.first?.id, "2")
    }
}
