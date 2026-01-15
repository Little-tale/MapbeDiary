//
//  AllLocationListViewReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation
import ReactorKit


final class AllLocationListViewReactor: Reactor {
    
    struct State: Equatable {
        let folderID: String
        var item: FolderEntity? = nil
        var realmError: RealmManagerError? = nil
        
        var showDeleteAlert: Bool = false
        var dismissTrigger: Bool = false
        
        var deleteMemoID: String? = nil
        var modifyTrigger: LocationMemoEntity? = nil
    }
    
    enum Action: Equatable {
        case viewDidLoad
        case loadData
        case reload
        case swipeAction(action: AllLocationVCView.SwipeActionType,index: Int)
        case checkedDelete
    }
    
    enum Mutation {
        case setShowDeleteAlert(Bool)
        case setDismissTrigger(Bool)
        case setDeleteMemoID(String?)
        case setItem(FolderEntity)
        case setRealmError(RealmManagerError)
        case removedItem(index: Int)
        case setModifiedTrigger(location: LocationMemoEntity)
    }
    
    var initialState: State
    let sharedService: SharedEventProtocol
    
    init(
        folderID: String,
        sharedService: SharedEventProtocol
    ) {
        self.initialState = State(folderID: folderID)
        self.sharedService = sharedService
    }
}

extension AllLocationListViewReactor {
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        let loadData = action
            .filter { $0 == .viewDidLoad }
            .map { _ in Action.loadData }

        return Observable.merge(action, loadData)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        case .loadData:
            return loadItems(state: currentState)
        case .reload:
            return loadItems(state: currentState)
        case .swipeAction(action: let action, index: let index):
            guard let item = currentState.item else { return .empty() }
            let memoItem = item.locationMemos[index]
            
            switch action {
            case .delete:
                return removeItem(item: memoItem, index: index)
            case .modify:
                return .just(.setModifiedTrigger(location: memoItem))
            }
        case .checkedDelete:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setShowDeleteAlert(trigger):
            state.showDeleteAlert = trigger
            
        case let .setDismissTrigger(trigger):
            state.dismissTrigger = trigger
            
        case let .setDeleteMemoID(id):
            state.deleteMemoID = id
            
        case let .setItem(item):
            state.item = item
            
        case let .setModifiedTrigger(trigger):
            state.modifyTrigger = trigger
            
        case let .setRealmError(error):
            state.realmError = error
            
        case let .removedItem(index):
            var copy = state.item?.locationMemos ?? []
            copy.remove(at: index)
            if let item = state.item {
                state.item = FolderEntity(
                    id: item.id,
                    name: item.name,
                    regDate: item.regDate,
                    modifyDate: item.modifyDate,
                    index: item.index,
                    locationMemos: copy
                )
            }
        }
        
        return state
    }
}

extension AllLocationListViewReactor {
    
    private func loadItems(state: State) -> Observable<Mutation> {
        return .run { send in
            let folderId = state.folderID
            let result = try await FolderRealmRepository.shared.findFolder(id: folderId)
            
            await send(.setItem(result))
            
        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .empty()
            }
            return .just(.setRealmError(error))
        }
    }
    
    private func removeItem(item: LocationMemoEntity, index: Int) -> Observable<Mutation> {
        return .run { [weak sharedService] send in
            try await MemoRealmRepository.shared.deleteLocationMemo(id: item.id)
            
            await send(.removedItem(index: index))
            
            sharedService?.send(.removedMemo(item))
        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .empty()
            }
            
            return .just(.setRealmError(error))
        }
    }
}
