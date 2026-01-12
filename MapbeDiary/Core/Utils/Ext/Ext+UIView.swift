//
//  Ext+UIView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit.UIView

extension UIView {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
