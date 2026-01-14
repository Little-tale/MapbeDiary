//
//  LocationMemoEntity.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation

struct LocationMemoEntity: Entity {
    let id: String
    let title: String
    let location: LocationEntity?
    let contents: String?
    let phoneNumber: String?
    let regDate: Date
    let detailMemos: [DetailMemoEntity]
}
