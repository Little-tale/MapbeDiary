//
//  UIAction.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 11/7/24.
//

import UIKit

extension UIAction {
    static func guardSelf<Object: AnyObject>(_ object: Object, handler: @escaping (Object, UIAction) -> Void) -> UIAction {
        return UIAction { [weak object] action in
            guard let object else { return }
            handler(object, action)
        }
    }
}
