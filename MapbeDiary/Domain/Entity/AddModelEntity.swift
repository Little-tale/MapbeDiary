//
//  AddModelEntity.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation

struct AddModelEntity: Equatable {
    let lat: String
    let lon: String
    var folder: String
    
    init(
        lat: String,
        lon: String,
        folder: String
    ) {
        self.lat = lat
        self.lon = lon
        self.folder = folder
    }
}
