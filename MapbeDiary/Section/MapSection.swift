//
//  MapSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation


enum MapAlertSection {
    case requestFail
    case noneAct
    case checkUserAut
    
    var title: String {
        switch self{
        case .requestFail:
            return "설정 이동 불가"
        case .noneAct:
            return "위치권한"
        case .checkUserAut:
            return "위치 권한이 필요합니다."
        }
    }
    var message: String{
        switch self {
        case .requestFail:
            return "설정 이동 불가"
        case .noneAct :
            return "위치권한을 허용 해주세요"
        case .checkUserAut:
            return "위치권한을 허용 해주세요"
        }
    }
    var actionTitle:String {
        switch self {
        case .requestFail:
            return "확인"
        case .noneAct:
            return ""
        case .checkUserAut:
            return "이동"
        }
    }
        var cancelTitle: String{
            return "취소"
        }
    
    static let noneName: String = "메모를 남겨요!"
}
