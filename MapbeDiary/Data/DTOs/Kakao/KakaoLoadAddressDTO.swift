//
//  KakaoLoadAddressDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

/// addressName 도로명 주소
struct RoadAddress: Decodable {
    /// 도로명주소
    let addressName: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
    }
}
