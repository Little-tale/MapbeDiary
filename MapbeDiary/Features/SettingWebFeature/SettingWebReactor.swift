//
//  SettingWebReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation
import ReactorKit
import RxSwift

final class SettingWebReactor: Reactor {
    
    struct State {
        var navigationTitle: String = ""
        var webUrlRequest: URLRequest?
        var viewDidLoad: Bool = false
        var action: SettingActionType? = nil
    }
    
    enum Action {
        case viewDidLoad
        case setAction(SettingActionType)
    }
    
    enum Mutation {
        case sendUrlRequest(URLRequest?)
        case sendWebViewTitle(String)
        case setViewDidLoad(Bool)
        case pendingAction(SettingActionType)
    }
    
    var initialState: State = State()
}

extension SettingWebReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewDidLoad:
            if let action = currentState.action {
                return startAction(action: action)
            }
            return .just(.setViewDidLoad(true))
            
        case let .setAction(action):
            if currentState.viewDidLoad == false {
                return .just(.pendingAction(action))
            }
            return startAction(action: action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .sendUrlRequest(urlRequest):
            state.webUrlRequest = urlRequest
            
        case let .sendWebViewTitle(title):
            state.navigationTitle = title
            
        case let .setViewDidLoad(bool):
            state.viewDidLoad = bool
            
        case let .pendingAction(action):
            state.action = action
        }
        
        return state
    }
}

// MARK: start Action
extension SettingWebReactor {
    
    private func startAction(action: SettingActionType) -> Observable<Mutation> {
        return .merge([
            .just(.sendUrlRequest(processing(action))),
            .just(.sendWebViewTitle(webViewTitle(action)))
        ])
    }
}

// MARK: Helper
extension SettingWebReactor {
    
    private func processing(_ action: SettingActionType) -> URLRequest? {
        var urlService: URL?
        
        switch action {
        case .customerSupport:
            urlService = URLs.customerSupport.url
            
        case .termsAndConditions:
            urlService = URLs.termsAndConditions.url
            
        case .initialize, .appVersion:
            urlService = nil
        }
        guard let urlService else { return nil }
        
        let urlRequest = makeURLRequest(urlService)
        
        return urlRequest
    }
    
    private func makeURLRequest(_ url: URL) -> URLRequest {
        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
    
    private func webViewTitle(_ action: SettingActionType) -> String {
        
        switch action {
        case .termsAndConditions:
            return "Setting_section_policies".localized
            
        case .customerSupport:
            return "Setting_section_help".localized
            
        default:
            return ""
        }
    }
}
