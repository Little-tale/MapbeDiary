//
//  ActionRouter.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

enum ActionRouter: String {
    case camera = "카메라"
    case gallery = "갤러리"
    
    func actions(actionHandler: @escaping ()-> Void) -> UIAlertAction {
        let action = UIAlertAction(title: self.rawValue, style: .default) { action in
            actionHandler()
        }
        return action
    }
}
