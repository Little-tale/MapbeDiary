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
                SettingModel(
                    title: "Setting_section_version".localized,
                    detail: "1.0",
                    actionType: .appVersion
                ),
                
                SettingModel(
                    title: "Setting_section_policies".localized,
                    detail: nil,
                    actionType: .termsAndConditions
                )
            ]
        case .info:
            return [
                SettingModel(
                    title: "Setting_section_help".localized,
                    detail: nil,
                    actionType: .customerSupport
                )
            ]
        case .delete:
            return [
                SettingModel(
                    title: "Setting_section_reset".localized,
                    detail: nil,
                    actionType: .initialize
                )
            ]
        }
        
    }
}

