//
//  Ext+UIScreen.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
