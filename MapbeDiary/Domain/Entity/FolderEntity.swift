//
//  FolderEntity.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import Foundation

struct FolderEntity: Entity {
    let id: String
    let name: String
    let regDate: Date
    let modifyDate: Date
    let index: Int
    var locationMemos: [LocationMemoEntity]
}

