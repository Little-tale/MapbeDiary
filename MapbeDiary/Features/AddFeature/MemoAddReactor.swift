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
    
    struct State {
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
    }
    
    enum Action {
        case sendImage(Data)
        case saveButtonTapped
        case folderButtonTapped
        case currentTitleTextChanged(String)
        case currentContentTextChanged(String)
        case currentPhoneNumberTextChanged(String)
        
        case setFolderID(String)
        case setAddModel(AddModel)
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
            return .empty()
            
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
                // TODO: Realm
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
        }
        
        return state
    }
}

// MARK: Helpers
extension MemoAddReactor {
  
}
