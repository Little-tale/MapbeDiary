//
//  KakaoLongLatDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

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
