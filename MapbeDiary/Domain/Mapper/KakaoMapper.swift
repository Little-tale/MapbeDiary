//
//  KakaoMapper.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

struct KakaoMapper {
    
    static func toEntity(with dtos: [PlaceDocumentDTO]) -> [PlaceDocumentEntity] {
        
        return dtos.map { toEntity(with: $0) }
    }
    
    static func toEntity(with dto: PlaceDocumentDTO) -> PlaceDocumentEntity {
        
        return PlaceDocumentEntity(
            phone: dto.phone,
            placeName: dto.placeName,
            roadAddressName: dto.roadAddressName,
            x: dto.x,
            y: dto.y,
            id: UUID()
        )
    }
}
