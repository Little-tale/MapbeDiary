//
//  CalendarMemoViewReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/16/26.
//

import Foundation
import RxSwift
import ReactorKit

final class CalendarMemoViewReactor: Reactor {
    
    struct State {
        let folder: FolderEntity
        
        var setCalendarDate = Date()
        var calendarDatas: [Date: [LocationMemoEntity]] = [:]
        var locationMemos: [LocationMemoEntity] = []
        var minimumDate: Date?
        
        @Pulse var calendarReloadTrigger = false
        @Pulse var realmError: RealmManagerError? = nil
        // MARK: 뭐가 목적인지 봐야함.
        @Pulse var selectedLocationMemo: LocationMemoEntity? = nil
    }
    
    enum Action {
        case viewDidLoad
        case selectedDate(Date)
        case selectedIndex(Int)
        case calendarDidChange(Date)
    }
    
    enum Mutation {
        case setMemos([LocationMemoEntity])
        case setRealmError(RealmManagerError)
        case setCurrentDate(Date)
        case setMinDate(Date)
        case setCalendarDatas([Date: [LocationMemoEntity]])
        case setSelectedLocationMemo(LocationMemoEntity)
        case setCalendarReloadTrigger(Bool)
    }
    
    var initialState: State
    
    init(folder: FolderEntity) {
        self.initialState = State(folder: folder)
    }
}

extension CalendarMemoViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewDidLoad:
            
            let folderID = currentState.folder.id
            let date = Date()
            
            return .concat([
                .just(.setCurrentDate(date)),
                findMinDate(folderID: folderID),
                findMonthEntities(folderID: folderID, date: date),
                findDateLocationMemos(date: date, folderID: folderID)
            ])
            
        case let .selectedDate(date):
            let folderID = currentState.folder.id
            
            return findDateLocationMemos(date: date, folderID: folderID)
            
        case let .selectedIndex(index):
            let current = currentState.locationMemos[index]
            
            return .just(.setSelectedLocationMemo(current))
            
        case let .calendarDidChange(date):
            let folderID = currentState.folder.id
            
            return findMonthEntities(folderID: folderID, date: date)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setMemos(memos):
            state.locationMemos = memos
            
        case let .setRealmError(error):
            state.realmError = error
            
        case let .setCurrentDate(date):
            state.setCalendarDate = date
            
        case let .setMinDate(date):
            state.minimumDate = date
            
        case let .setCalendarDatas(datas):
            state.calendarDatas = datas
            
        case let .setSelectedLocationMemo(memo):
            state.selectedLocationMemo = memo
            
        case let .setCalendarReloadTrigger(trigger):
            state.calendarReloadTrigger = trigger
        }
        
        return state
    }
}

// MARK: Realm
extension CalendarMemoViewReactor {
    
    private func findDateLocationMemos(date: Date, folderID: String) -> Observable<Mutation> {
        return .run { send in
            let result = try await MemoRealmRepository.shared.findLocationMemos(
                folderId: folderID,
                date: date
            )
            await send(.setMemos(result))

        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .empty()
            }
            return .just(.setRealmError(error))
        }
    }
    
    private func findMinDate(folderID: String) -> Observable<Mutation> {
        return .run { send in
            let min = try await MemoRealmRepository.shared.findMinDateLocationMemo(
                folderId: folderID
            )
            await send(.setMinDate(min?.regDate ?? Date()))
        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .empty()
            }
            return .just(.setRealmError(error))
        }
    }
    
    private func findMonthEntities(folderID: String, date: Date) -> Observable<Mutation> {
        return .run { send in
            let result = try await MemoRealmRepository.shared.findLocationMemosByMonthGroupedByDate(
                folderId: folderID,
                month: date
            )
            await send(.setCalendarDatas(result))
            await send(.setCalendarReloadTrigger(true))
        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .empty()
            }
            return .just(.setRealmError(error))
        }
    }
}
