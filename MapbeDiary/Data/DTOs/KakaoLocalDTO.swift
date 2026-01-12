//
//  KakaoLocalDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

struct KakaoLocalDTO: Decodable {
    let documents: [PlaceDocumentDTO]
    let meta: Meta
}
