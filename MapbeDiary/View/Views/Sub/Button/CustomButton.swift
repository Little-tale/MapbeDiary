//
//  SaveButton.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

class CustomButton {
    
//    static func saveCreate(title: String, target: Any?, action: Selector) -> UIBarButtonItem {
//        let button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
//        button.tintColor = UIColor.gray
//        return button
//    }
//    
//    static func backCreate(target: Any?, action: Selector) -> UIBarButtonItem {
//        let backImage = UIImage(systemName: "chevron.backward")
//        let button = UIBarButtonItem(image: backImage, style: .plain, target: target, action: action)
//        button.tintColor = UIColor.gray
//        return button
//    }
    
    static func folderButton() -> UIButton {
        let view = UIButton()
         var configu = UIButton.Configuration.tinted()
         configu.imagePadding = 8
         view.configuration = configu
         return view
    }
    

    
    static func imageChangeButton() -> UIButton {
        let view = UIButton()
        var configu = UIButton.Configuration.tinted()
        configu.title = AddViewSection.chagngeButtonTitle
        configu.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer{ atrubute in
            var before = atrubute
            before.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            return before
        }
        view.configuration = configu


        return view
    }
}
