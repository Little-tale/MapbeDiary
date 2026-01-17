//
//  AboutMemoReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/17/26.
//

import Foundation
import ReactorKit

final class AboutMemoReactor: Reactor {
    
    struct State {
        let memoID: String
        let detailMemoID: String?
        let imageMaxCount = 3
        let maxTextCount = 300
        var imageDatas: [Data] = []
        var currentTextViewText: String = ""
        
        var deleteButtonHidden: Bool = true
        
        @Pulse var showPhotoActionSheet = false
        @Pulse var showAlreadyMaxImages = false
        @Pulse var showImageViewer: Data? = nil
        @Pulse var realmError: RealmManagerError? = nil
        @Pulse var fileManagerError: FileManagerError? = nil
        @Pulse var showWarningToast: (title: String?, message: String?)? = nil
        @Pulse var didSaveSuccess = false
        @Pulse var didRemoveSuccess = false
    }
    
    enum Action {
        case viewDidLoad
        case saveButtonTapped
        case addImageButtonTapped
        case sendImages([Data])
        case sendRemoveImageIndex(index: Int)
        case requestShowImage(index: Int)
        case removeTapped
        case setCurrentText(text: String)
    }
    
    enum Mutation {
        case setShowPhotoActionSheet(Bool)
        case setImageDatas(datas: [Data])
        case addImageDatas([Data])
        case setShowAlreadyMaxImages(Bool)
        case removeImageData(at: Int)
        case requestShowImage(index: Int)
        case setCurrentText(text: String)
        case setRealmError(error: RealmManagerError)
        case setWarningText(title: String?, message: String?)
        case setDidSaveSuccess(Bool)
        case setDeleteButtonHidden(Bool)
        case setDidRemoveSuccess(Bool)
    }
    
    var initialState: State
    
    init(
        memoID: String,
        detailMemoID: String?
    ) {
        self.initialState = State(
            memoID: memoID,
            detailMemoID: detailMemoID
        )
    }
}

extension AboutMemoReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            if let detailID = currentState.detailMemoID {
                return .concat([
                    loadDetailMemo(detailMemoID: detailID),
                    .just(.setDeleteButtonHidden(false))
                ])
                
            } else {
                return .just(.setDeleteButtonHidden(true))
            }
            
            
        case .saveButtonTapped:
            let state = currentState
            if !checkSaveState(state: state) {
                return .just(
                    .setWarningText(
                        title: MapTextSection.essentialTitle.alertTitle,
                        message: MapTextSection.essentialTitle.alertMessage
                    )
                )
            } else {
                return saveDetailMemo(
                    state: state
                )
            }
            
        case .addImageButtonTapped:
            let count = currentState.imageDatas.count
            let max = currentState.imageMaxCount
            if count < max {
                return .just(.setShowPhotoActionSheet(true))
            } else {
                return .just(.setShowAlreadyMaxImages(true))
            }
            
        case let .sendImages(datas):
            return .just(.addImageDatas(datas))
            
        case let .sendRemoveImageIndex(index):
            return .just(.removeImageData(at: index))
            
        case let .requestShowImage(index):
            return .just(.requestShowImage(index: index))
            
        case .removeTapped:
            guard let detailID = currentState.detailMemoID else {
                return .empty()
            }
            return removeDetailMemo(detailID: detailID)
            
        case let .setCurrentText(text):
            return .just(.setCurrentText(text: text))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setImageDatas(datas):
            state.imageDatas = datas
            
        case let .addImageDatas(images):
            state.imageDatas.append(contentsOf: images)
            
        case let .setShowPhotoActionSheet(bool):
            state.showPhotoActionSheet = bool
            
        case let .setShowAlreadyMaxImages(bool):
            state.showAlreadyMaxImages = bool
            
        case let .removeImageData(at):
            state.imageDatas.remove(at: at)
            
        case let .requestShowImage(index):
            let item = state.imageDatas[index]
            state.showImageViewer = item
            
        case let .setCurrentText(text):
            state.currentTextViewText = text
            
        case let .setRealmError(error):
            state.realmError = error
            
        case let .setWarningText(title, message):
            state.showWarningToast = (title, message)
            
        case let .setDidSaveSuccess(bool):
            state.didSaveSuccess = bool
            
        case let .setDeleteButtonHidden(bool):
            state.deleteButtonHidden = bool
            
        case let .setDidRemoveSuccess(bool):
            state.didRemoveSuccess = bool
        }
        
        return state
    }
}

extension AboutMemoReactor {
    
    private func checkSaveState(state: State) -> Bool {
        let contents = state.currentTextViewText
        return !contents.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: Realm
extension AboutMemoReactor {
    
    private func loadDetailMemo(detailMemoID: String) -> Observable<Mutation> {
        return .run { send in
            let result = try await DetailMemoRealmRepository.shared.findDetailMemo(id: detailMemoID)
            
            await send(.setCurrentText(text: result.detailContents))
            
            let imageDatas = result.imagePaths.compactMap { try? Data(contentsOf: $0) }
            
            await send(.setImageDatas(datas: imageDatas))
            
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error: error))
        }
    }
    
    private func saveDetailMemo(
        state: State
    ) -> Observable<Mutation>{
        return .run { send in
            try await DetailMemoRealmRepository.shared.updateDetailMemo(
                input: DetailMemoUpdateInput(
                    detailMemoId: state.detailMemoID,
                    locationMemoId: state.memoID,
                    text: state.currentTextViewText,
                    imageDatas: state.imageDatas
                )
            )
            await send(.setDidSaveSuccess(true))
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error: error))
        }
    }
    
    private func removeDetailMemo(detailID: String) -> Observable<Mutation> {
        return .run { send in
            try await DetailMemoRealmRepository.shared.deleteDetailMemo(
                detailId: detailID
            )
            await send(.setDidRemoveSuccess(true))
        }.catch { error in
            guard let error = error as? RealmManagerError else { return .empty() }
            return .just(.setRealmError(error: error))
        }
    }
}
