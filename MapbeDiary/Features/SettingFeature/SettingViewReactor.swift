//
//  SettingViewReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation
import RxSwift
import ReactorKit

final class SettingViewReactor: Reactor {
    
    struct State {
        var realmError: RealmManagerError? = nil
        var successTrigger: Bool = false
    }
    
    enum Action {
        case callDeleteInfo
    }
    
    enum Mutation {
        case successRemove
        case realmError(RealmManagerError)
    }
    
    enum SettingActionType {
        case appVersion
        case termsAndConditions
        case customerSupport
        case initialize
    }
    
    var initialState: State = State()
}

// MARK: Flow Logic
extension SettingViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .callDeleteInfo:
            
            return .run { send in
                let repository = await FolderRealmRepository.shared
                
                guard let currentID = UserDefaultsManager.currentFolderID else {
                    print("ERROR - Can't Find folderID ")
                    return
                }
                                
                try await repository.removeFolderInEveryThing(
                    folderId: currentID
                )
                
                await send(.successRemove)
            } .catch { error in
                guard let error = error as? RealmManagerError else {
                    return .empty()
                }
                return .just(.realmError(error))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        
        case .realmError(let error):
            state.realmError = error
            
        case .successRemove:
            state.successTrigger = true
        }
        return state
    }
}
