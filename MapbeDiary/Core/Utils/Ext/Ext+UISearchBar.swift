//
//  Ext+UISearchBar.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit

extension UISearchBar {
    
    
    /// TextField background Color Setting
    /// - Parameters:
    ///   - color: UIColor
    ///   - transparentBackground: whole background Color Remove
    func setTextFieldBackground(color: UIColor, transparentBackground: Bool = true) {
        if transparentBackground {
            // 서치바의 전체 배경을 투명하게 설정
            self.backgroundImage = UIImage()
        }
        
        // 서치바 내부의 UITextField를 찾아서 배경색을 설정
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = color
        }
    }
    
}
