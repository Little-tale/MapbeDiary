//
//  ActionRouter.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

struct ActionRouter {
    
    enum ActionType {
        case camera
        case gallery
        case cancel
        
        var title: String {
            switch self {
            case .camera:
                return "Authority_Camera".localized
            case .gallery:
                return "Authority_Gallery".localized
            case .cancel:
                return "Cancel_check_title".localized
            }
        }
    }
    
    func actions(_ type: ActionType, actionHandler: @escaping ()-> Void) -> UIAlertAction {
        let action = UIAlertAction(title: type.title , style: .default) { action in
            actionHandler()
        }
        
        return action
    }
    var cancel: UIAlertAction {
        let action = UIAlertAction(title: ActionType.cancel.title, style: .cancel)
        return action
    }
}
