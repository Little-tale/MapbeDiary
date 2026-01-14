//
//  DetailMemoEntity.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation

struct DetailMemoEntity: Entity {
    let id: String
    let detailContents: String
    let regDate: Date
    let modifyDate: Date
    let imagePaths: [URL]
}
