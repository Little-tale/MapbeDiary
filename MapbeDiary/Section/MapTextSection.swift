//
//  AlertSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit

enum MapTextSection {
    case requestFail
    case noneAct
    case checkUserAut
    case panelError
    case camera
    case delete
    case dismiss
    case essentialTitle
    case bringPhoto
    
    var alertTitle: String? {
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
        case .essentialTitle:
            return "텍스트 필수!"
        case .bringPhoto:
            return "사진 가져오기"
        }
    }
    var alertMessage: String? {
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
        case .essentialTitle:
            return "텍스트는 필수입니다!"
        case .bringPhoto:
            return nil
        }
    }
    var actionTitle:String? {
        switch self {
        case .requestFail:
            return "확인"
        case .noneAct:
            return nil
        case .checkUserAut, .camera:
            return "이동"
        case .panelError:
            return nil
        case .delete:
            return "삭제"
        case .dismiss:
            return "뒤로가기"
        case .essentialTitle:
            return nil
        case .bringPhoto:
            return nil
        }
    }
    var cancelTitle: String{
            return "취소"
    }
    
    static let noneName: String = "메모를 남겨요!"
    static let saveTitle: String = "저장"
    
    static let beginningSoon: String = "준비중 이에요!"
    static let emptyLabelText: String = "장소의 기억을\n남겨보세요!"
    static let emptySearcBarText: String = "장소를 검색해보세요!"
    static let searchEmptyText: String = "검색하실 장소를\n입력해주세요!"
    static let cancel: String = "취소"
}
