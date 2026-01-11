//
//  Ext+UILabel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit.UILabel

extension UILabel {
    
    func asFont(targetString: String) {
        let fullText = text ?? ""
        
        let attributeString = NSMutableAttributedString(string: fullText)
        // 범위 + 대소문자 구분없이
        let range = (fullText as NSString).range(of: targetString, options: .caseInsensitive)
        
        attributeString.addAttribute(.foregroundColor ,value: UIColor.wheetOrange , range: range)
        
        attributedText = attributeString
    }
}
