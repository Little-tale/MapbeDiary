//
//  AlertSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit

enum MapAlertSection {
    case requestFail
    case noneAct
    case checkUserAut
    case panelError
    case camera
    case delete
    case dismiss
    
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
        case .camera:
            return "카메라 권한"
        case .delete:
            return "삭제"
        case .dismiss:
            return "뒤로가기"
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
        case .camera:
            return  "카메라 권한을 허용 해주세요"
        case .delete:
            return "삭제 하시면 복구 하실수 없습니다!"
        case .dismiss:
            return "저장이 반영되지 않았습니다!"
        }
    }
    var actionTitle:String {
        switch self {
        case .requestFail:
            return "확인"
        case .noneAct:
            return ""
        case .checkUserAut, .camera:
            return "이동"
        case .panelError:
            return ""
        case .delete:
            return "삭제"
        case .dismiss:
            return "뒤로가기"
        }
    }
    var cancelTitle: String{
            return "취소"
    }
    
    static let noneName: String = "메모를 남겨요!"
    
}
