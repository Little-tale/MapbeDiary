//
//  WidgetAction.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import Foundation


enum WidgetAction {
    
    static let widgetAppGroup = "group.com.SilverGun.MapbeDiary"
    
    case search
    
    var actionKey: String {
        switch self {
        case .search:
            return "widget_action"
        }
    }
    
    var action: String {
        switch self {
        case .search:
            return "search"
        }
    }
    
    var path: String {
        switch self {
        case .search:
            return "widget://Search"
        }
    }
}
