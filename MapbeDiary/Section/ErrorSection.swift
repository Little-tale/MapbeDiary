//
//  ErrorSection.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

enum RealmManagerError: Error {
    case canMakeFolder
    case canMakeMemo
    case cantDeleteOfFolder
    case cantSortedOfFolder
    case cantDeleteMemo
    case cantAddMemoInFolder
    case canModifiMemo
    case cantAddImage
    case cantDeleteImage
    case cantFindObjectId
    case cantModifyMemo
    
    var alertMessage: String {
        switch self {
        case .canMakeFolder:
            "폴더를 생성할 수 없습니다. 잠시후 재시도 해주세요!"
        case .canMakeMemo:
            "메모를 생성할 수 없습니다. 잠시후 재시도 해주세요!"
        case .cantDeleteOfFolder:
            "폴더를 제거할 수 없습니다. 잠시후 재시도 해주세요!"
        case .cantSortedOfFolder:
            "폴더 정렬에 실패 했습니다... 관리자에게 문의해주세요!"
        case .cantDeleteMemo:
            "메모를 제거할 수 없습니다. 잠시후 재시도 해주세요!"
        case .cantAddMemoInFolder:
            "폴더에 메모를 넣는중 에러가 발생했습니다.\n잠시후 재시도 바랍니다."
        case .canModifiMemo:
            "메모를 수정할 수 없습니다. 관리자에게 문의해주세요!"
        case .cantAddImage:
            "이미지 추가중 문제가 발생했습니다. 관리자에 문의 해주세요!"
        case .cantDeleteImage:
            "이미지 제거중 문제가 발생했습니다. 관리자에 문의 해주세요!"
        case .cantFindObjectId:
            "파일을 찾지 못했어요!"
        case .cantModifyMemo:
            "수정 할수 없어요!"
        }
    }
}


enum cameraError {
    static var titleString: String = "가져오기 싪패"
    static var messageString: String = "사진을 가져오는 도중 문제가 발생했습니다!"
}



