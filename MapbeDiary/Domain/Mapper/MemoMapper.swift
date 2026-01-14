//
//  MemoMapper.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation

struct MemoMapper {
    
    static func toEntity(_ dto: DetailMemo) -> DetailMemoEntity {
        let imageIds = Array(dto.imagePaths.map { $0.id.stringValue })
        let imagePaths: [URL]
        
        switch FileManagers.shard.findDetailImageDataUrl(
            detailID: dto.id.stringValue,
            imageIds: imageIds
        ) {
        case let .success(urls):
            imagePaths = urls
        case .failure:
            imagePaths = []
        }
        
        return DetailMemoEntity(
            id: dto.id.stringValue,
            detailContents: dto.detailContents,
            regDate: dto.regDate,
            modifyDate: dto.modifeyDate,
            imagePaths: imagePaths
        )
    }
    
    static func toEntity(_ dto: LocationMemo) -> LocationMemoEntity {
        let locationEntity: LocationEntity?
        if let location = dto.location {
            locationEntity = LocationEntity(lat: location.lat, lon: location.lon)
        } else {
            locationEntity = nil
        }
        
        return LocationMemoEntity(
            id: dto.id.stringValue,
            title: dto.title,
            location: locationEntity,
            contents: dto.contents,
            phoneNumber: dto.phoneNumber,
            regDate: dto.regdate,
            detailMemos: dto.detailMemos.map { toEntity($0) }
        )
    }
    
    static func toEntities(_ dtos: [DetailMemo]) -> [DetailMemoEntity] {
        dtos.map { toEntity($0) }
    }
    
    static func toEntities(_ dtos: [LocationMemo]) -> [LocationMemoEntity] {
        dtos.map { toEntity($0) }
    }
}
