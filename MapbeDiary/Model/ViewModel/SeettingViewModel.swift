//
//  SeettingViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import Foundation




// Setting Model
struct SettingModel:Hashable {
    let title : String
    let detail: String?
    let uuid = UUID()
    let actionType: SettingActionType
}

enum SettingActionType {
    case appVersion
    case termsAndConditions
    case customerSupport
    case initialize
}

enum SettingSection: CaseIterable {
    case setting
    case info
    case delete
    
    var data: [SettingModel] {
        switch self {
        case .setting:
            return  [
                SettingModel(title: "앱 버전 정보", detail: "1.0", actionType: .appVersion),
                SettingModel(title: "약관 및 정책", detail: nil, actionType: .termsAndConditions)
            ]
        case .info:
            return [SettingModel(title: "고객 센터", detail: nil, actionType: .customerSupport)]
        case .delete:
            return [SettingModel(title: "초기화", detail: nil, actionType: .initialize)]
        }
    }
}

