//
//  ImageSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit.UIImage

enum ImageSection: String {
    case defaultMarkerImage = "defaultMarker"
    case defaultFolderImage = "defaultFolderImage"
    
    
    var image: UIImage {
        switch self {
        case .defaultMarkerImage:
            return .defaultMarker
        case .defaultFolderImage:
            return .defaultFolder
        }
    }
}
