//
//  ErrorSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

enum RealmManagerError: Error {
    case canMakeFolder
    case canMakeMemo
    case cantDeleteOfFolder
    case cantSortedOfFolder
    case cantDeleteMemo
    case cantAddMemoInFolder
    case canModifiMemo
    case cantAddImage
    case cantDeleteImage
    case cantFindObjectId
    case cantModifyMemo
    case sameDetailMemoError
    case cantMakeDetailMemo
    case cantAddImageObject
    case cantDeleteDetailMemo
    case cantDeleteLocationMemo
    case cantFindLocationMemo
    
    var alertMessage: String {
        switch self {
        case .canMakeFolder:
            "Error_cant_make_folder".localized
            
        case .canMakeMemo:
            "Error_cant_make_location_memo".localized
            
        case .cantDeleteOfFolder:
            "Error_cant_delete_folder".localized
            
        case .cantSortedOfFolder:
            "Error_cant_sorted_Folder".localized
            
        case .cantDeleteMemo, .cantDeleteDetailMemo, .cantDeleteLocationMemo:
            "Error_cant_delete_local_memo".localized
            
        case .cantAddMemoInFolder:
            "Error_cant_add_memo_in_folder".localized
            
        case .canModifiMemo:
            "Error_cant_modify_memo".localized
            
        case .cantAddImage:
            "Error_cant_add_image".localized
            
        case .cantDeleteImage:
            "Error_cant_delete_image".localized
            
        case .cantFindObjectId:
            "Error_cant_find_File".localized
            
        case .cantModifyMemo:
            "Error_you_cant_modify_memo".localized
            
        case .sameDetailMemoError:
            "Error_same_memo".localized
            
        case .cantMakeDetailMemo:
            "Error_cant_make_detail_Memo".localized
            
        case .cantAddImageObject:
            "Error_you_cant_add_image".localized
            
        case .cantFindLocationMemo:
            "Error_cant_find_location_memo".localized
            
        }
    }
}


enum cameraError {
    static var titleString: String = "Error_camera_cant_take".localized
    static var messageString: String = "Error_cant_take_image".localized
}



