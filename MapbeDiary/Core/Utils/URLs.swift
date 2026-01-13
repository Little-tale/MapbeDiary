//
//  URLs.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation

enum URLs {
    /// 약관, 정책
    case termsAndConditions
    /// 고객센터
    case customerSupport
    
}

extension URLs {
    var url: URL? {
        switch self {
        case .termsAndConditions:
            URL(string: "https://uneven-lute-2a1.notion.site/882adb18a7f34e4a8f3cdb49426ab553?pvs=4")
        case .customerSupport:
            URL(string: "https://uneven-lute-2a1.notion.site/d669dbe68558430f95ac223da59dc3f9?pvs=4")
        }
    }
}
