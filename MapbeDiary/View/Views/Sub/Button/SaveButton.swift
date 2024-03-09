//
//  SaveButton.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

class CustomButton {
    static func saveCreate(title: String, target: Any?, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        button.tintColor = UIColor.gray
        return button
    }
    static func backCreate(target: Any?, action: Selector) -> UIBarButtonItem {
        let backImage = UIImage(systemName: "chevron.backward")
        let button = UIBarButtonItem(image: backImage, style: .plain, target: target, action: action)
        button.tintColor = UIColor.gray
        return button
    }
}
