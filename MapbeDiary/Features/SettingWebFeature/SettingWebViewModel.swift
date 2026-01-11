//
//  WebViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import Foundation


class SettingWebViewModel {

    var inputSettingActionType: _Observable<SettingActionType?> = _Observable(nil)
    
    var outputURL: _Observable<URLRequest?> = _Observable(nil)
    
    var outputNaviTitle: _Observable<String?> = _Observable(nil)
    
    var webLoadCompilte: _Observable<Void?> = _Observable(nil)
    
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
            outputNaviTitle.value = "Setting_section_policies".localized
        case .customerSupport:
            outputNaviTitle.value = "Setting_section_help".localized
        case .initialize:
            break
        }
    }
 
    deinit {
        print("deinit - SettingWebViewModel")
    }
}
