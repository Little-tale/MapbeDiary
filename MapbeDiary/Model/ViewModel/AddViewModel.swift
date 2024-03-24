//
//  AddViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

struct addModel {
    let lat: String
    let lon: String
    var folder: String
    
    init(lat: String, lon: String, folder: String) {
        self.lat = lat
        self.lon = lon
        self.folder = folder
    }
}


class AddViewModel {
    // ------- In Put ------
    // lat: String, lon: String, folder: Folder
   
    // 폴더 아이디
    let changeFolder: Observable<Folder?> = Observable(nil)
    
    let saveButtonTrigger: Observable<Void?> = Observable(nil)
    
    // 새로 올때의 모델
    let coordinateTrigger: Observable<(addModel)?> = Observable(nil)
    // MARK: 수정시 Input ------ LocationMemoId
    let modifyTrigger: Observable<String?> = Observable(nil)
    
    // MARK: 공통 iNput -------
    
    
    // ------- Out Put -----
    let proceccingSuccessOutPut: Observable<addViewOutStruct?> = Observable(nil)
    
    //let memoSuccessOutPut: Observable<AddOrModifyModel?> = Observable(nil)
    
    let saveButtonOutPutImage: Observable<String?> = Observable(nil)
    
    let urlErrorOutPut: Observable<URLSessionManagerError?> = Observable(nil)
    
    let realmError: Observable<RealmManagerError?> = Observable(nil)
    let dismisstrigger: Observable<Void?> = Observable(nil)
    
    // ------- Static -------
    let repository = RealmRepository()
    var titleName = String()
    var searchTitle: String?
    var folder: Folder?
    var imageChangeTrigger = false
    var tempSaveModel = addViewOutStruct()
    //var saveEnd : AddOrModifyModel?
    //var modifyEnd : AddOrModifyModel?
    
    init(){
        coordinateTrigger.bind {[weak self] coordi in
            guard let self else {return}
            guard let coordi else {return}
            newProceccing(coordi)
        }
//        changeFolder.bind {[weak self] folder in
//            guard let self else {return}
//            guard let folder else {return}
//            findFolderName(folder: folder)
//        }
        saveButtonTrigger.bind { [weak self] void in
            guard let self else {return}
            guard void != nil else {return}
            saveButtonClicked()
        }
        modifyTrigger.bind { [weak self] memoId in
            guard let memoId else { return }
            guard let self else { return }
            findMemo(memoId:memoId)
        }
    }
    // folder
    private func newProceccing(_ model: addModel ){
        repository.findFolder(folderId: model.folder) {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                folder = success
                if NetWorkServiceMonitor.shared.isConnected {
                    apiRequest(lat: model.lat, lon: model.lon, folder: success)
                    return
                } else {
                    noNetworkProcecing(model)
                }
            case .failure(let failure):
                realmError.value = failure
            }
        }
    }
    
    
    // MARK: API 요청을 통해 현지 정보를 가져옵니다.
    private func apiRequest(lat: String, lon: String, folder: Folder){
        print(lat, lon)
        URLSessionManager.shared.fetch(type: KaKakaoCordinateModel.self, api: KakaoApiModel.cordinate(x: lon, y: lat)) {
            [weak self] results in
            guard let self else { return }
            switch results {
            case .success(let success):
                urlProccing(model:success, folder: folder)
            case .failure(let fail): print("카카오 에러쓰")
                urlErrorOutPut.value = fail
            }
        }
    }
    // MARK: 네트워크 없을때 작동합니다.
    private func noNetworkProcecing(_ model: addModel){
        proceccingSuccessOutPut.value = addViewOutStruct()
    }
    
    // MARK: API 모델을 알맞은 모델로 수정합니다.
    private func urlProccing(model : KaKakaoCordinateModel, folder: Folder) {
        print(model.documents.first?.roadAddress.addressName)
        var data = addViewOutStruct(
            titlePlacHolder: model.documents.first?.roadAddress.addressName
        )
        if let searchTitle {
            data.titlePlacHolder = searchTitle
        }
        proceccingSuccessOutPut.value = data
    }

    
    private func saveButtonClicked(){
        let result = tempSaveModel
        if let start = coordinateTrigger.value {
            print("마커",result.memoImage ?? "")
            let location = Location(lat: start.lat, lon: start.lon)
            print(result)
            guard let folder else { return }
            saveOnlyNew(result, location: location, folder: folder)
        } else {
            modifySave(tempSaveModel)
        }
        
    }
    
    private func saveOnlyNew(_ model:  addViewOutStruct, location: Location, folder: Folder) {
        repository.makeMemoMarkerAtFolders( model: model, location: location, folder: folder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                dismisstrigger.value = ()
            case .failure(let failure):
                realmError.value = failure
            }
        }
    }
    
    private func modifySave(_ model: addViewOutStruct){
        if let memoId = model.memoId {
            repository.findLocationMemo(ojidString: memoId) {[weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    repository.modifyMemo(structure: model, locationMemo: success) { [weak self]
                        results  in
                        guard let weakSelf = self else { return }
                        if case.failure(let failure) = results {
                            weakSelf.realmError.value = failure
                        }
                    }
                    imagePag()
                case .failure(let failure):
                    realmError.value = failure
                }
            }
        }
    }
        
    
    // MARK: 이미지 저장 수정해야함
    func imagePag(){

        guard let memoId = tempSaveModel.memoId else { return  }
        guard let imageData = tempSaveModel.memoImage else {
            dismisstrigger.value = ()
            return
        }
        if imageChangeTrigger {
            if !FileManagers.shard.saveMarkerZipImageForMemo(memoId: memoId, imageData: imageData) {
                realmError.value = RealmManagerError.canModifiMemo
            } else {
                if !FileManagers.shard.saveMarkerImageForMemo(memoId: memoId, imageData: imageData) {
                    
                    realmError.value = RealmManagerError.canModifiMemo
                }
            }
        }
        dismisstrigger.value = ()
    }
    // MARK: $$$$ 지우는 거 해야함.
    
    
    
    // MARK: 메모스트링 아이디를 통해 메모를 찾아옵니다.
    private func findMemo(memoId: String){
        repository.findId(IdString: memoId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                if let memo = repository.findLocationMemo(ojID: success),
                   let folder = repository.findMemoAtFolder(memo: memo){
                    
                    modifyStartProceccing(memo: memo, folder: folder)
        
                }
            case .failure(let failure):
                print(failure.alertMessage)
            }
        }
    }
    
    func modifyStartProceccing(memo: LocationMemo, folder: Folder){
        // proceccingSuccessOutPut
        var model = addViewOutStruct(
            title: memo.title,
            titlePlacHolder: nil,
            content: memo.contents,
            phoneNumber: memo.phoneNumber,
            folderimage: nil,
            regDate: memo.regdate,
            memoId: memo.id.stringValue,
            folderName: folder.folderName,
            modifyTrigger: true
            )
        FileManagers.shard.findMarkerImage(memoId: memo.id.stringValue) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                model.memoImage = success
            case .failure(let failure):
                realmError.value = failure
            }
        }
        proceccingSuccessOutPut.value = model
        tempSaveModel = model
    }
    
    private func textFiledTestster(string: String){
        if string.count >= 16 {
            
        }
    }
}


//    private func findFolderName(folder: Folder) {
//        guard coordinateTrigger.value == nil else { return }
//        var model = proceccingSuccessOutPut.value
//        model?.folder = folder
//        proceccingSuccessOutPut.value = model
//    }
//            do {
//                try repository.makeMemoMarkerAtFolders( model: result, location: location)
//
//            } catch (let error) {
//                realmError.value = error as? RealmManagerError
//            }
            //        } else {
            //            guard memoSuccessOutPut.value != nil else { return }
            //            do {
            //                guard let modifyEnd else {return}
            //                print("###",modifyEnd)
            //                try repository.modifyMemo(structure: modifyEnd)
            //                if modifyEnd.modiFy{
            //                    if modifyEnd.markerImage != nil {
            //                        imagePag()
            //                    }
            //                }
            //            } catch (let error) {
            //                realmError.value = error as? RealmManagerError
            //            }
            //        }
// location
/*repository.makeMemoAtFolder(folder: result.folder, memo: memo)*/
// memo
//        let memo = repository.makeMemoModel(addViewStruct: result, location: location)
// putInFolder
// ---------------------

//                    let model = AddOrModifyModel(memo: memo, folder: folder)
//
//                    memoSuccessOutPut.value = model
//                    modifyEnd = model
