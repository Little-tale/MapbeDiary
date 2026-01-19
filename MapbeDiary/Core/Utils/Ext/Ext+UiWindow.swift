//
//  Ext+UiWindow.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit

//UI Screen.main.bound 대체
extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}
