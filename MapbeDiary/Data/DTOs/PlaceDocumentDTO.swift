//
//  PlaceDocumentDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

// MARK: - 도로명 주소 장소이름 전화번호 x,y lon lat
/// 도로명 , 장소이름, 전화번호,
struct PlaceDocumentDTO: Hashable, Decodable {
    let phone, placeName: String // 전화번호, 장소이름
    let roadAddressName, x, y: String // 도로명 주소 , lat lon
//    let id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case phone
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x, y
    }
}
