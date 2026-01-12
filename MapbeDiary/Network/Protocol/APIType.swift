//
//  APIType.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

/// API 타입 + 각 API의 에러 수집
protocol APIType{
    var query : [URLQueryItem]? {get} // API 쿼리
    var header : [String: String] {get} // API 헤더
    var method : String? {get} // API 메서드 정의 없으면 기본 GET
    var scheme : String?{get} // url 스키마 정의 없으면 기본 "https:"
    var host: String {get} // url 호스트
    var path: String {get} // url path
    /// 에러코드에 따른 에러 케이스를 주셔야합니다.
    func errorCodeCase(stateCode: Int) -> ApiTypeError?
}
