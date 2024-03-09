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
    
    var placeHolder: String {
        switch self {
        case .titleTextFieldText:
            "여기는 어디일까요?"
        case .simpleMemoTextFiled:
            "간단한 메모를 남겨보세요!"
        }
    }
    
    
}
