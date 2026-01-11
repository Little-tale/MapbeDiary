//
//  OnboardReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/11/26.
//

import Foundation
import ReactorKit
import RxSwift

final class OnboardReactor: Reactor {
    
    // MARK: Property
    
    struct State {
        var buttonAlpha: Double = 0.0
        var animated = false
        var error: RealmManagerError? = nil
        var nextVC: Bool = false
    }
    
    enum Action {
        case startButtonTapped
        case currentPageIdxChanged(index: Int, imageCount: Int)
    }
    
    enum Mutation {
        case changeButtonAlpha(Double)
        case showErrorAlert(error: RealmManagerError)
        case nextVC(Bool)
    }
    
    var initialState: State = State()
    
    private let repository = RealmRepository()
    
}

// MARK: Flow Logic
extension OnboardReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startButtonTapped:
            do {
                try repository.makeFolder(folderName: "추억의 공간")
                let folder = repository.findAllFolderArray().first
                
                // MARK: FIXME
                SingleToneDataViewModel.shared.shardFolderOb.value = folder
                
                return .just(.nextVC(true))
            } catch {
                return .just(.showErrorAlert(error: .canMakeFolder))
            }
            
        case let .currentPageIdxChanged(idx, count):
            
            if (idx + 1) == count {
                return .just(.changeButtonAlpha(1.0))
            }
        }
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .changeButtonAlpha(let double):
            if state.animated { return state }
            
            state.buttonAlpha = double
            state.animated = true
            
        case let .showErrorAlert(error):
            state.error = error
            
        case let .nextVC(bool):
            state.nextVC = bool
        }
        
        
        return state
    }
}
