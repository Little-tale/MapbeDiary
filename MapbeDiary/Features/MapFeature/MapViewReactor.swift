//
//  MapViewReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import CoreLocation
import Foundation
import RxSwift
import ReactorKit

final class MapViewReactor: Reactor {
    
    struct State {
        var currentMemos: [LocationMemoEntity] = []
        var location: CLLocationCoordinate2D? = nil
        
        var currentLocationState: CLAuthorizationStatus? = nil
        
        var moveToSetRegion: CLLocationCoordinate2D? = nil
        
        @Pulse var moveToSearch: Bool = false
        @Pulse var moveToSetting: Bool = false
        @Pulse var showSettingAlert: Bool = false
        @Pulse var showsUserLocation: Bool = false
        @Pulse var realmError: RealmManagerError? = nil
        
        var sendCalendarView: FolderEntity? = nil
    }
    
    enum Action: Equatable {
        case viewDidLoad
        case checkLocationWhenInUseAuthorization
        case loadFolder
        case changeFolder(folderID: String)
        case setDeepLink(String?)
        case calendarButtonTapped
    }
    
    enum Mutation {
        case setRealmError(RealmManagerError)
        case setMemos([LocationMemoEntity])
        case setMoveToSearch
        case setCurrentLocation(CLAuthorizationStatus)
        case setLocation(CLLocationCoordinate2D)
        case setShowSettingAlert
        case setShowsUserLocation
        case sendCalendarView(FolderEntity?)
        case setDefaultLocation
    }
    
    let sharedEvent: SharedEventProtocol
    private let locationManager: LocationManager
    
    var initialState: State = State()
    
    init(
        sharedEvent: SharedEventProtocol,
        locationManager: LocationManager
    ) {
        self.sharedEvent = sharedEvent
        self.locationManager = locationManager
    }
}

extension MapViewReactor {
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        let shared = sharedEvent.event.flatMap { event -> Observable<Action> in
            switch event {
            case .removedMemo(_):
                return .just(.loadFolder)
            case .needReloadMemos:
                return .just(.loadFolder)
            default:
                return .empty()
            }
        }
        
        let checkLocationState = action.filter { $0 == .viewDidLoad }
            .flatMap { event -> Observable<Action> in
                return .merge([
                    .just(.loadFolder),
                    .just(.checkLocationWhenInUseAuthorization),
                ])
            }
        
        return Observable.merge(action, shared, checkLocationState)
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let widgetAction = sharedEvent.event.flatMap { event -> Observable<Mutation> in
            guard case let .widgetAction(action) = event else { return .empty() }
            switch action {
            case .search:
                return .just(.setMoveToSearch)
            }
        }
        
        let currentAuthState = locationManager.rx
            .currentAuthState
            .flatMap { event -> Observable<Mutation> in
                return .just(.setCurrentLocation(event))
            }
        
        let didChangeAuthorization = locationManager.rx
            .didChangeAuthorization
            .flatMap { event -> Observable<Mutation> in
                return .just(.setCurrentLocation(event))
            }
        
        let didUpdateLocation = locationManager.rx
            .didUpdateLocation
            .flatMap { event -> Observable<Mutation> in
                return .just(.setLocation(event))
            }
        
        return Observable.merge(
            mutation,
            widgetAction,
            currentAuthState,
            didChangeAuthorization,
            didUpdateLocation
        )
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFolder:
            return findFolder()
            
        case let .changeFolder(folderID):
            return findFolder(folderID: folderID)
            
        case let .setDeepLink(linkString):
            guard let linkString else { return .empty() }
            
            if linkString == "widget://Search" {
                return .just(.setMoveToSearch)
            }
        case .checkLocationWhenInUseAuthorization:
            locationManager.requestAuthorization()
            
            return .empty()
            
        case .viewDidLoad:
            return .just(.setDefaultLocation)
            
        case .calendarButtonTapped:
            guard let id = UserDefaultsManager.currentFolderID else {
                return .empty()
            }
            
            return .run { send in
                let result = try await FolderRealmRepository.shared.findFolder(id: id)
                await send(.sendCalendarView(result))
                await send(.sendCalendarView(nil))
            }.catch { error in
                guard let error = error as? RealmManagerError else {
                    return .just(.setRealmError(.cantFindFolder))
                }
                return .just(.setRealmError(error))
            }
        }
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setRealmError(error):
            state.realmError = error
            
        case let .setMemos(memo):
            state.currentMemos = memo
            
        case .setMoveToSearch:
            state.moveToSearch = true
            
        case let .setCurrentLocation(locationState):
            switch locationState {
            case .denied:
                state.showSettingAlert = true
                state.showsUserLocation = false
                
            case .authorizedAlways, .authorizedWhenInUse:
                state.showsUserLocation = true
                
            default:
                state.showSettingAlert = false
                state.showsUserLocation = false
            }
            state.currentLocationState = locationState
            
        case let .setLocation(location):
            state.location = location
            
        case .setShowSettingAlert:
            state.showSettingAlert.toggle()
            
        case .setShowsUserLocation:
            state.showsUserLocation.toggle()
            
        case let .sendCalendarView(model):
            state.sendCalendarView = model
            
        case .setDefaultLocation:
            let location = LocationManager.defaultLocation
            state.location = location
        }
        
        return state
    }
}

// MARK: Realm
extension MapViewReactor {
    
    private func findFolder(folderID: String? = nil) -> Observable<Mutation> {
        let id = folderID ?? UserDefaultsManager.currentFolderID
        
        guard let id else {
            return .just(.setRealmError(.cantFindFolder))
        }
        
        return .run { send in
            let result = try await MemoRealmRepository.shared.findLocationMemos(
                folderId: id
            )
            
            await send(.setMemos(result))
        }.catch { error in
            guard let error = error as? RealmManagerError else {
                return .just(.setRealmError(.cantFindFolder))
            }
            return .just(.setRealmError(error))
        }
    }
}
