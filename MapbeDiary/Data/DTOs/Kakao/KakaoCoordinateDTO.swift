//
//  KakaoCoordinateDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

/// # KAKAO LongLat Model
/// x,y 를 통해 도로명 주소를 가져옵니다.
struct KakaoCoordinateModel: Decodable {
    let documents:[LongLat]
}
