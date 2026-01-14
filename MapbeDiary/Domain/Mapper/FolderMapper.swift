//
//  FolderMapper.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation

struct FolderMapper {
    
    static func toEntity(_ dto: Folder) -> FolderEntity {
        FolderEntity(
            id: dto.id.stringValue,
            name: dto.folderName,
            regDate: dto.regDate,
            modifyDate: dto.modifyDate,
            index: dto.index,
            locationMemos: dto.LocationMemo.map { MemoMapper.toEntity($0) }
        )
    }
    
    static func toEntities(_ dtos: [Folder]) -> [FolderEntity] {
        dtos.map { toEntity($0) }
    }
}
