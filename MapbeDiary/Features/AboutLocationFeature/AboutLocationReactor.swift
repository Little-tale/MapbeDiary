//
//  AboutLocationReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import Foundation
import RxSwift
import ReactorKit

final class AboutLocationReactor: Reactor {
    
    struct State {
        let memoID: String
        var locationMemo: LocationMemoEntity? = nil
        var detailMemos: [DetailMemoEntity] = []
        
        @Pulse var realmError: RealmManagerError? = nil
        @Pulse var modifyRequest: (memoID: String, item: DetailMemoEntity)? = nil
        @Pulse var isEmptyDetails = true
        @Pulse var successRemoveMemo = false
    }
    
    enum Action {
        case viewDidLoad
        case modifyRequest(DetailMemoEntity)
        case removeRequest
        case removeDetail(model: DetailMemoEntity, index: Int)
        case reLoadData
    }
    
    enum Mutation {
        case setLocationMemo(LocationMemoEntity)
        case setRealmError(RealmManagerError)
        case setDetailMemos([DetailMemoEntity])
        case setModifyRequest(memoID: String, item: DetailMemoEntity)
        case successRemoveDetail(index: Int)
        case setIsEmptyDetails(Bool)
        case setSuccessRemoveMemo(Bool)
    }
    
    var initialState: State
    let sharedEvent: SharedEventProtocol
    
    init(
        memoID: String,
        shared: SharedEventProtocol
    ) {
        self.initialState = State(memoID: memoID)
        self.sharedEvent = shared
    }
}

extension AboutLocationReactor {
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        let reloadAction = sharedEvent.event
            .filter { $0 == .needReloadMemos }
            .map { _ in Action.reLoadData }
        
        return .merge([
            action, reloadAction
        ])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let id = currentState.memoID
            return loadLocationMemo(memoID: id)
            
        case .reLoadData:
            let id = currentState.memoID
            return loadLocationMemo(memoID: id)
            
        case let .modifyRequest(model):
            let id = currentState.memoID
            return .just(.setModifyRequest(memoID: id, item: model))
            
        case .removeRequest:
            let id = currentState.memoID
            return removeLocationMemo(memoID: id)
            
        case let .removeDetail(model, index):
            return removeDetailMemo(detailID: model.id, index: index)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setLocationMemo(memo):
            state.locationMemo = memo
            
        case let .setRealmError(error):
            state.realmError = error
            
        case let .setDetailMemos(datas):
            state.detailMemos = datas
            
        case let .setModifyRequest(id, model):
            state.modifyRequest = (id, model)
            
        case let .successRemoveDetail(index):
            state.detailMemos.remove(at: index)
            state.isEmptyDetails = state.detailMemos.isEmpty
            
        case let .setIsEmptyDetails(trigger):
            state.isEmptyDetails = trigger
            
        case let .setSuccessRemoveMemo(trigger):
            if trigger {
                sharedEvent.send(.needReloadMemos)
            }
            state.successRemoveMemo = trigger
        }
        
        return state
    }
}

// MARK: Realm
extension AboutLocationReactor {
    
    private func loadLocationMemo(memoID: String) -> Observable<Mutation> {
        return .run { send in
            let result = try await MemoRealmRepository.shared.findLocationMemo(
                id: memoID
            )
            await send(.setLocationMemo(result))
            await send(.setDetailMemos(result.detailMemos))
            await send(.setIsEmptyDetails(result.detailMemos.isEmpty))
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error))
        }
    }
    
    private func removeDetailMemo(detailID: String, index: Int) -> Observable<Mutation> {
        return .run { send in
            try await DetailMemoRealmRepository.shared.deleteDetailMemo(
                detailId: detailID
            )
            await send(.successRemoveDetail(index: index))
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error))
        }
    }
    
    private func removeLocationMemo(memoID: String) -> Observable<Mutation> {
        return .run { send in
            try await MemoRealmRepository.shared.deleteLocationMemo(id: memoID)
            await send(.setSuccessRemoveMemo(true))
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error))
        }
    }
}
