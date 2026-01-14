//
//  MemoAddReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation
import ReactorKit
import RxSwift

@available(*, deprecated, renamed: "MemoAddReactor.State", message: "Use MemoAddReactor.State instead")
struct addViewOutStruct: Equatable, Sendable {
    var title: String?
    var titlePlacHolder: String?
    var content: String?
    var phoneNumber: String?
    var folderimage: String?
    var regDate = Date() // 일단 대기
    var memoImage: Data?
    var memoId: String?
    var folderName: String?
    var modifyTrigger: Bool = false
}

final class MemoAddReactor: Reactor {
    
    struct State: Equatable {
        var title: String?
        var titlePlacHolder: String?
        var content: String?
        var phoneNumber: String?
        var folderimage: String?
        var regDate = Date()
        var memoImage: Data?
        var memoId: String? // 있으면 수정 모드
        var folderName: String?
        
        var folderId : String?
        
        var kakaoPlaceHolder: String? = nil
        var realmError: RealmManagerError? = nil
        var networkError: NetworkManagerError? = nil
        var dismissTrigger: Bool = false
        
        var lat: String = ""
        var lon: String = ""
    }
    
    enum Action {
        case sendImage(Data)
        case saveButtonTapped
        case folderButtonTapped
        case currentTitleTextChanged(String)
        case currentContentTextChanged(String)
        case currentPhoneNumberTextChanged(String)
        
        case setFolderID(String)
        case setAddModel(AddModelEntity)
        case setKakaoData(PlaceDocumentEntity)
        case setMemoID(String)
    }
    
    enum Mutation {
        case setImage(Data)
        case setTitle(String)
        case setTitlePlaceHolder(String)
        case setContent(String)
        case setPhoneNumber(String)
        case setFolderID(String)
        case setRealmError(RealmManagerError)
        case setNetworkError(NetworkManagerError)
        case setMemoID(String)
        case setLocation(lat: String, lon: String)
        case setDismissTrigger(Bool)
    }
    
    var initialState: State
    
    init(initialState: State = State()) {
        self.initialState = initialState
    }
}

extension MemoAddReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .sendImage(data):
            return .just(.setImage(data))
            
        case .saveButtonTapped:
            let state = currentState
            
            let title: String
            let kakao = state.kakaoPlaceHolder ?? ""
            let getTitle = state.title ?? ""
            if ( !kakao.isEmpty && getTitle.isEmpty ) {
                title = kakao
            } else {
                title = state.title ?? "Empty Title"
            }
            
            if let memoID = state.memoId {
                return .run { send in
                    try await MemoRealmRepository.shared.updateLocationMemo(
                        input: LocationMemoUpdateInput(
                            memoId: memoID,
                            title: title,
                            contents: state.content,
                            phoneNumber: state.phoneNumber,
                            markerImageData: state.memoImage
                        )
                    )
                    await send(.setDismissTrigger(true))
                }.catch { error in
                    guard let error = error as? RealmManagerError else { return .empty() }
                    return .just(.setRealmError(error))
                }
            }
            // Location(lat: start.lat, lon: start.lon)
            return .run { [state] send in
               
                
                try await MemoRealmRepository.shared.createLocationMemo(
                    input: LocationMemoCreateInput(
                        title: title,
                        contents: state.content,
                        phoneNumber: state.phoneNumber,
                        location: Location(
                            lat: state.lat,
                            lon: state.lon
                        ),
                        folderId: state.folderId ?? "",
                        markerImageData: state.memoImage
                    )
                )
                
                // FIXME: 정상적으로 저장되나 맵 업데이트 문제
                await send(.setDismissTrigger(true))
                
            }.catch { error in
                guard let error = error as? RealmManagerError else {
                    return .empty()
                }
                return .just(.setRealmError(error))
            }
            
        case .folderButtonTapped:
            return .empty()
            
        case let .currentTitleTextChanged(text):
            return .just(.setTitle(text))
            
        case let .currentContentTextChanged(text):
            return .just(.setContent(text))
            
        case let .currentPhoneNumberTextChanged(text):
            return .just(.setPhoneNumber(text))
            
        case let .setFolderID(id):
            return .concat([
                .just(.setFolderID(id))
            ])
            
        case let .setAddModel(model):
            return .run { send in
                
                await send(.setFolderID(model.folder))
                await send(.setLocation(lat: model.lat, lon: model.lon))
                
                if !NetWorkServiceMonitor.shared.isConnected { return }
                
                let result = await NetworkManager.fetch(
                    type: KakaoCoordinateModel.self,
                    api: KakaoApiRouter.coordinate(
                        x: model.lon,
                        y: model.lat
                    )
                )
                switch result {
                case let .success(model):
                    let placeHolder = model.documents.first?.roadAddress.addressName ?? AddViewSection.titleTextFieldText.placeHolder
                    
                    await send(.setTitlePlaceHolder(placeHolder))
                case let .failure(error):
                    await send(.setNetworkError(error))
                }
            }
            
        case let .setKakaoData(data):
            let title = data.placeName
            return .just(.setTitle(title))
            
        case let .setMemoID(id):
            return .concat([
                .just(.setMemoID(id)),
                .run { send in
                    let result = try await MemoRealmRepository.shared.findLocationMemo(id: id)
                    
                    await send(.setTitle(result.title))
                    await send(.setContent(result.contents ?? ""))
                    await send(.setPhoneNumber(result.phoneNumber ?? ""))
                    
                    await send(.setTitle(result.title))
                    let imageResult = await FileManagers.shard.findMarkerImage(memoId: id)
                    
                    switch imageResult {
                        
                    case let .success(data):
                        guard let data else { return }
                        await send(.setImage(data))
                        
                    case .failure:
                        return
                    }
                    
                }.catch { error in
                    guard let error = error as? RealmManagerError else { return .empty() }
                    return .just(.setRealmError(error))
                }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setImage(data):
            state.memoImage = data
            
        case let .setTitle(title):
            state.title = title
            
        case let .setTitlePlaceHolder(text):
            state.titlePlacHolder = text
            state.kakaoPlaceHolder = text
            
        case let .setContent(content):
            state.content = content
            
        case let .setPhoneNumber(number):
            state.phoneNumber = number
            
        case let .setFolderID(id):
            state.folderId = id
            
        case let .setRealmError(error):
            state.realmError = error
            
        case let .setNetworkError(error):
            state.networkError = error
            
        case let .setMemoID(id):
            state.memoId = id
            
        case let .setLocation(lat, lon):
            state.lat = lat
            state.lon = lon
            
        case let .setDismissTrigger(bool):
            state.dismissTrigger = bool
        }
        
        return state
    }
}

// MARK: Helpers
extension MemoAddReactor {
  
}
