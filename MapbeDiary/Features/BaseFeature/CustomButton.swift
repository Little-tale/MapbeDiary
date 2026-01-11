//
//  SaveButton.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit

class CustomButton {
    
    
    static func folderButton() -> UIButton {
        let view = UIButton()
         var configu = UIButton.Configuration.tinted()
         configu.imagePadding = 8
        configu.baseForegroundColor = .wheetBlack
         view.configuration = configu
         return view
    }

    static func imageChangeButton() -> UIButton {
        let view = UIButton()
        var configu = UIButton.Configuration.tinted()
        configu.title = AddViewSection.chagngeButtonTitle
        configu.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer{ atrubute in
            var before = atrubute
            before.font = JHFont.UIKit.bo10
            return before
        }
        view.configuration = configu


        return view
    }
}
