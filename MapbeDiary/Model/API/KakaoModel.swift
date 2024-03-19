//
//  KakaoModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation

// MARK: 카카오 로컬 검색
struct KakaoLocalModel: Decodable {
    let documents: [Document]
    let meta: Meta
}


// MARK: - 도로명 주소 장소이름 전화번호 x,y lon lat
/// 도로명 , 장소이름, 전화번호,
struct Document: Hashable, Decodable {
    let phone, placeName: String // 전화번호, 장소이름
    let roadAddressName, x, y: String // 도로명 주소 , lat lon
    let id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case phone
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x, y
    }
}

// MARK: 토탈, 끝인지, 페이지수
/// 끝인가?, 페이지 토탈, 토탈
struct Meta: Decodable {
    let isEnd: Bool // 현재 끝 페이지인지
    let pageableCount: Int // 페이지 토탈수
    let totalCount: Int // 전체 수

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}

/// -----------------------------------------------------
// COORDINATE

// MARK: KAKAO LongLat Model
// x,y 를 통해 도로명 주소를 가져옵니다.
struct KaKakaoCordinateModel: Decodable {
    let documents:[LongLat]
}
/// documents -> 도로병 주소 구조체 roadAddress
struct LongLat: Decodable {
    var roadAddress: RoadAddress // 도로명주소 구조체
    let address: Address
    
    enum CodingKeys: String, CodingKey {
        case roadAddress = "road_address"
        case address
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(Address.self, forKey: .address)
        // -------------------------------------
        if let roadAddress = try container.decodeIfPresent(RoadAddress.self, forKey: .roadAddress) {
            self.roadAddress = roadAddress
            
        } else {
            self.roadAddress = RoadAddress(addressName: address.address_name)
        }
    }
}
/// addressName 도로명 주소
struct RoadAddress: Decodable {
    let addressName: String // 도로명주소
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
    }
}

struct Address: Decodable {
    let address_name: String // 일반적 주소
}

