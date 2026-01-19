//
//  KakaoApiErrors.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

enum KaKaoErrors: Int, CaseIterable, ApiTypeError{
    case clientError = 400 // 해결방법 재시도
    case tokenError = 401 // 해더 오류 문제
    case authError = 402 // 권한 오류
    case quarterError = 429 // 사용량 초과
    case serverInternalError = 500 // 시스템 오류
    case serviceUnavailable = 503 // 서버 점검중
    
    var errorCode: Int {
        return self.rawValue
    }
    
    var message: String{
        switch self {
        case .clientError, .tokenError, .authError:
            return "Kakao_error_message_type1".localized
        case .quarterError:
            return "Kakao_error_message_type2".localized
        case .serverInternalError:
            return "Kakao_error_message_type3".localized
        case .serviceUnavailable:
            return "Kakao_error_message_type4".localized
        }
    }
}
