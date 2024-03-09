//
//  AddViewSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation


enum AddViewSection {
    case titleTextFieldText
    case simpleMemoTextFiled
    case phoneNumberTextLabel
    case phoneNuberTextField
    
    var placeHolder: String {
        switch self {
        case .titleTextFieldText:
            "Add_title_text_fileld_text".localized
        case .simpleMemoTextFiled:
            "Add_simple_text_filed_text".localized
        case .phoneNumberTextLabel:
            "Add_phone_number_text_label".localized
        case .phoneNuberTextField:
            "전화번호가 있나요?"
        default :
            ""
        }
    }
    static var saveButtonText: String = "Add_save_button_text".localized
    static var defaultTitle: String = "Add_default_Text".localized
    static let chagngeButtonTitle: String = "이미지 변경"
}

