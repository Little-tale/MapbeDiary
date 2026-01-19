//
//  KakaoApiRouter.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

enum KakaoApiRouter: APIType {
    
    case keywordLocation(text: String, page: Int, x: Double? = nil, y: Double? = nil)
    
    case coordinate(x: String, y: String)
    
}

// MARK: Items
extension KakaoApiRouter {
    var query: [URLQueryItem]? {
        switch self {
        case .keywordLocation(let text, let page, let x, let y):
            let searchItem = URLQueryItem(name: "query", value: text)
            let xItem = URLQueryItem(name: "x", value: String(x ?? 126.9778222))
            let yItem = URLQueryItem(name: "y", value: String(y ?? 37.5664056))
            let redius = URLQueryItem(name: "redius", value: "100")
            let page = URLQueryItem(name: "page", value: String(page))
            return [searchItem,xItem,yItem,redius,page]
        case .coordinate(x: let x, y: let y):
            let xItem = URLQueryItem(name: "x", value: x)
            let yItem = URLQueryItem(name: "y", value: y)
            return [xItem,yItem]
        }
    }
    
    var header: [String : String] {
        return APIKey.kakao.headers
    }
    var method: String? {return nil}
    
    var scheme: String? {return nil}
    
    var host: String {
        return "dapi.kakao.com"
    }
    
    var path: String {
        switch self {
        case .keywordLocation:
            return "/v2/local/search/keyword"
        case .coordinate:
            return "/v2/local/geo/coord2address"
        }
    }
    
    func errorCodeCase(stateCode: Int) -> ApiTypeError? {
        let error = KaKaoErrors.allCases.filter { errorCase in
            errorCase.rawValue == stateCode
        }
        if error.isEmpty{
            return nil
        } else {
            return error.first
        }
    }
}
