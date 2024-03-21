//
//  WebViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import Foundation


class SettingWebViewModel {

    var inputSettingActionType: Observable<SettingActionType?> = Observable(nil)
    
    var outputURL: Observable<URLRequest?> = Observable(nil)
    
    var outputNaviTitle: Observable<String?> = Observable(nil)
    
    init(){
        inputSettingActionType.bind { [weak self] settingAction in
            guard let self else { return }
            guard let settingAction else { return }
            processing(settingAction)
            webViewTitle(settingAction)
        }
    }
    private func processing(_ action: SettingActionType) {
        var urlService: URL?
        
        switch action {
        case .termsAndConditions:
            urlService = URL(string: "https://uneven-lute-2a1.notion.site/882adb18a7f34e4a8f3cdb49426ab553?pvs=4")
        case .customerSupport:
            urlService = URL(string: "https://uneven-lute-2a1.notion.site/d669dbe68558430f95ac223da59dc3f9?pvs=4")
            
        case .initialize, .appVersion:
            urlService = nil
        }
        guard let urlService else { return }
        
        makeURLRequest(urlService)
    }
    
    private func makeURLRequest(_ url: URL){
        let urlRequest = URLRequest(url: url)
        outputURL.value = urlRequest
    }
    
    private func webViewTitle(_ action: SettingActionType) {
        switch action {
        case .appVersion:
            break
        case .termsAndConditions:
            outputNaviTitle.value = "약관내용"
        case .customerSupport:
            outputNaviTitle.value = "고객 센터"
        case .initialize:
            break
        }
    }
}
