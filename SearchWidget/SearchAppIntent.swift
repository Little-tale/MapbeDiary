//
//  SearchAppIntent.swift
//  SearchWidget
//
//  Created by Jae hyung Kim on 3/25/25.
//

import AppIntents

struct SearchAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Search"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: WidgetAction.widgetAppGroup)
        defaults?.set(WidgetAction.search.action, forKey: WidgetAction.search.actionKey)
        return .result()
    }
}
