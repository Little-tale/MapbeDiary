//
//  NetworkManagerError.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

/// URLSessinManger 에서 나올수 있는 대략적인 에러
enum NetworkManagerError: Error{
    case noData // 데이터가 없습니다.
    case noResponse // 응답이 없습니다.
    case errorResponseCode // 응답코드가 200이 아니며, 문서에도 없습니다.
    case failRequest // 요청을 실패합니다.
    case errorDecoding // 디코딩을 실패합니다.
    case cantStatusCoding // 상태 코드로 변경할수 없습니다.
    case componentsError // 컴포넌츠 변경에 문제가 발생했습니다.
    case unknownError // 예상치 못한 경우 입니다.
    case apiError(ApiTypeError) // API 관련 에러입니다.
    
    /// 공통 에러 메시지
    var errorMessage: String {
        switch self {
        case .noData:
            return "API_error_Response".localized
        case .noResponse:
            return"API_error_Response".localized
        case .errorResponseCode:
            return "API_error_Response".localized
        case .failRequest:
            return "API_error_Request".localized
        case .errorDecoding:
            return "API_error_Response".localized
        case .cantStatusCoding:
            return "API_error_Response".localized
        case .componentsError:
            return "API_error_Response".localized
        case .unknownError:
            return "API_error_Response".localized
        case .apiError(let apiTypeError):
            return apiTypeError.message
        }
    }
    
}
