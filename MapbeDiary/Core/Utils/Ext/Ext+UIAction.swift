//
//  Ext+UIAction.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit

extension UIAction {
    
    static func guardSelf<Object: AnyObject>(_ object: Object, handler: @escaping (Object, UIAction) -> Void) -> UIAction {
        return UIAction { [weak object] action in
            guard let object else { print("object is nil"); return }
            handler(object, action)
        }
    }
}
