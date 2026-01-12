//
//  APITypeError.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

// MARK: API TypeError의 필수 요건
protocol ApiTypeError: Error {
    var errorCode: Int { get } // 에러코드에 따라 메시지가 반영됩니다.
    var message: String { get } // 이 메시지가 구현됩니다.
}
