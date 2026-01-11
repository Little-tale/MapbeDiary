//
//  Ext+String.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

// MARK: 다국어 확장
extension String {
    
    /// 다국어
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
