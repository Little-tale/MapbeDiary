//
//  KakaoMetaDTO.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

// MARK: 토탈, 끝인지, 페이지수
/// 끝인가?, 페이지 토탈, 토탈
struct Meta: Decodable {
    let isEnd: Bool // 현재 끝 페이지인지
    let pageableCount: Int // 페이지 토탈수
    let totalCount: Int // 전체 수

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
