//
//  KakaoMapperTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class KakaoMapperTests: XCTestCase {
    func test_toEntity_mapsFields() {
        let dto = PlaceDocumentDTO(
            phone: "010-1234-5678",
            placeName: "Mapbe Cafe",
            roadAddressName: "123 Road",
            x: "127.0",
            y: "37.0"
        )

        let entity = KakaoMapper.toEntity(with: dto)

        XCTAssertEqual(entity.phone, dto.phone)
        XCTAssertEqual(entity.placeName, dto.placeName)
        XCTAssertEqual(entity.roadAddressName, dto.roadAddressName)
        XCTAssertEqual(entity.x, dto.x)
        XCTAssertEqual(entity.y, dto.y)
    }

    func test_toEntity_withList_assignsUniqueIDs() {
        let dto1 = PlaceDocumentDTO(
            phone: "010-0000-0000",
            placeName: "A",
            roadAddressName: "Road A",
            x: "1",
            y: "2"
        )
        let dto2 = PlaceDocumentDTO(
            phone: "010-1111-1111",
            placeName: "B",
            roadAddressName: "Road B",
            x: "3",
            y: "4"
        )

        let entities = KakaoMapper.toEntity(with: [dto1, dto2])

        XCTAssertEqual(entities.count, 2)
        XCTAssertNotEqual(entities[0].id, entities[1].id)
    }
}
