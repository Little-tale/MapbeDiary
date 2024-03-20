//
//  AlertSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit

enum MapTextSection {
    case requestFail
    case noneAct
    case checkUserAut
    case panelError
    case camera
    case delete
    case dismiss
    case essentialTitle
    case bringPhoto
    
    var alertTitle: String? {
        switch self{
        case .requestFail:
            return "Alert_requestFail".localized
        case .noneAct:
            return "Alert_noneAct".localized
        case .checkUserAut:
            return "Alert_checkUserLocalAut".localized
        case .panelError:
            return "Alert_panelError".localized
        case .camera:
            return "Alert_camera".localized
        case .delete:
            return "Alert_delete".localized
        case .dismiss:
            return "Alert_dismiss".localized
        case .essentialTitle:
            return "Alert_essentialTitle".localized
        case .bringPhoto:
            return "Alert_bringPhoto".localized
        }
    }
    var alertMessage: String? {
        switch self {
        case .requestFail:
            return "Alert_requestFail".localized
        case .noneAct :
            return "Alert_checkNeedLocalAut".localized
        case .checkUserAut:
            return "Alert_checkNeedLocalAut".localized
        case .panelError:
            return "Alert_needAdmin".localized
        case .camera:
            return  "Alert_needACameraAut".localized
        case .delete:
            return "Alert_cantRecover".localized
        case .dismiss:
            return "Alert_none_reflect_saves".localized
        case .essentialTitle:
            return "Alert_require_Text".localized
        case .bringPhoto:
            return nil
        }
    }
    var actionTitle:String? {
        switch self {
        case .requestFail:
            return "Alert_check_title".localized
        case .noneAct:
            return nil
        case .checkUserAut, .camera:
            return "Alert_move".localized
        case .panelError:
            return nil
        case .delete:
            return "Alert_delete".localized
        case .dismiss:
            return "Alert_dismiss".localized
        case .essentialTitle:
            return nil
        case .bringPhoto:
            return nil
        }
    }
    var cancelTitle: String{
        return "Cancel_check_title".localized
    }
    
    static let noneName: String = "Text_take_Memo".localized
    static let saveTitle: String = "Add_save_button_text".localized
    
    static let beginningSoon: String = "Bring_soon".localized
    static let emptyLabelText: String = "Leave_memory".localized
    static let emptySearcBarText: String = "Search_place".localized
    static let searchEmptyText: String = "Search_empty_text".localized
    static let cancel: String = "Cancel_check_title".localized
}
