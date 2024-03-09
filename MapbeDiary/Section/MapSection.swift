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
    case panelError
    
    var title: String {
        switch self{
        case .requestFail:
            return "설정 이동 불가"
        case .noneAct:
            return "위치권한"
        case .checkUserAut:
            return "위치 권한이 필요합니다."
        case .panelError:
            return "치명적 오류"
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
        case .panelError:
            return "관리자에게 문의하세요!"
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
        case .panelError:
            return ""
        }
    }
    var cancelTitle: String{
            return "취소"
    }
    
    static let noneName: String = "메모를 남겨요!"
    
}
