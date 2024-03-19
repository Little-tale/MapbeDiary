//
//  KakaoAPIModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation

enum KakaoApiModel: APIType {
    
    // 키워드 로컬 검색 API
    case keywordLocation(text: String, page: Int, x: Double? = nil, y: Double? = nil)
    
    case cordinate(x: String, y: String)
    
    
    var query: [URLQueryItem]? {
        switch self {
        case .keywordLocation(let text, let page, let x, let y):
            let serchItem = URLQueryItem(name: "query", value: text)
            let xItem = URLQueryItem(name: "x", value: String(x ?? 126.9778222))
            let yItem = URLQueryItem(name: "y", value: String(y ?? 37.5664056))
            let redius = URLQueryItem(name: "redius", value: "100")
            let page = URLQueryItem(name: "page", value: String(page))
            return [serchItem,xItem,yItem,redius,page]
        case .cordinate(x: let x, y: let y):
            let xItem = URLQueryItem(name: "x", value: x)
            let yItem = URLQueryItem(name: "y", value: y)
            return [xItem,yItem]
        }
    }
    
    var header: [String : String] {
        return APIKey.kakao.headers
    }
    var method: String? {return nil}
    
    var schem: String? {return nil}
    
    var host: String {
        return "dapi.kakao.com"
    }
    
    var path: String {
        switch self {
        case .keywordLocation:
            return "/v2/local/search/keyword"
        case .cordinate:
            return "/v2/local/geo/coord2address"
        }
    }
    
    func errorCodeCase(stateCode: Int) -> ApiTypeError? {
        let error = KaKaoErrors.allCases.filter {  errorCase in
            errorCase.rawValue == stateCode
        }
        if error.isEmpty{
            return nil
        } else {
            return error.first
        }
    }
    
    
}

enum KaKaoErrors:Int, CaseIterable, ApiTypeError{
    case clietnError = 400 // 해결방법 재시도
    case tokkenError = 401 // 해더 오류 문제
    case authError = 402 // 권한 오류
    case queterError = 429 // 사용량 초과
    case serverInternalError = 500 // 시스템 오류
    case serviceUnavailable = 503 // 서버 점검중
    
    var errorCode: Int {
        return self.rawValue
    }
    
    var message: String{
        switch self {
        case .clietnError, .tokkenError, .authError:
            return "Kakao_error_message_type1".localized
        case .queterError:
            return "Kakao_error_message_type2".localized
        case .serverInternalError:
            return "Kakao_error_message_type3".localized
        case .serviceUnavailable:
            return "Kakao_error_message_type4".localized
        }
    }
}

