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
    var folder: Folder
    
    init(lat: String, lon: String, folder: Folder) {
        self.lat = lat
        self.lon = lon
        self.folder = folder
    }
}


class AddViewModel {
    // ------- In Put ------
    // lat: String, lon: String, folder: Folder
    let coordinateTrigger: Observable<(addModel)?> = Observable(nil)
    
    let changeFolder: Observable<Folder?> = Observable(nil)
    
    let saveButtonTrigger: Observable<Void?> = Observable(nil)
    
    // MARK: 수정시 Input ------
    let modifyTrigger: Observable<String?> = Observable(nil)
    
    
    // MARK: 공통 iNput -------
    
    
    // ------- Out Put -----
    let urlSuccessOutPut: Observable<addViewOutStruct?> = Observable(nil)
    
    let memoSuccessOutPut: Observable<memoModifyOutstruct?> = Observable(nil)
    
    let saveButtonOutPutImage: Observable<String?> = Observable(nil)
    
    let urlErrorOutPut: Observable<URLSessionManagerError?> = Observable(nil)
    
    let realmError: Observable<RealmManagerError?> = Observable(nil)
    
    
    // ------- Static -------
    let repository = RealmRepository()
    var titleName = String()
    var searchTitle: String?
    
    var saveEnd : memoModifyOutstruct?
    var modifyEnd : memoModifyOutstruct?
    
    init(){
        coordinateTrigger.bind {[weak self] coordi in
            guard let self else {return}
            guard let coordi else {return}
            apiRequest(lat: coordi.lat, lon: coordi.lon, folder: coordi.folder)
        }
        changeFolder.bind {[weak self] folder in
            guard let self else {return}
            guard let folder else {return}
            findFolderName(folder: folder)
        }
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
    // MARK: API 요청을 통해 현지 정보를 가져옵니다.
    private func apiRequest(lat: String, lon: String, folder: Folder){
        print(lat, lon)
        URLSessionManager.shared.fetch(type: KaKakaoCordinateModel.self, api: KakaoApiModel.cordinate(x: lon, y: lat)) {
            [weak self] results in
            guard let self else { return }
            switch results {
            case .success(let success):
                proccing(model:success, folder: folder)
            case .failure(let fail):
                urlErrorOutPut.value = fail
            }
        }
    }
    // MARK: API 모델을 알맞은 모델로 수정합니다.
    private func proccing(model : KaKakaoCordinateModel, folder: Folder) {
        var data = addViewOutStruct(title:AddViewSection.defaultTitle,titlePlacHolder: model.documents.first?.roadAddress.addressName, folder: folder)
        
        
        if let searchTitle {
            data.titlePlacHolder = searchTitle
        }
        urlSuccessOutPut.value = data
    }
    
    
    private func findFolderName(folder: Folder) {
        guard coordinateTrigger.value == nil else { return }
        var model = urlSuccessOutPut.value
        model?.folder = folder
        urlSuccessOutPut.value = model
    }
    
    private func saveButtonClicked(){
        
        if let result = urlSuccessOutPut.value {
            guard let start = coordinateTrigger.value else { return }
            print("마커",result.memoImage ?? "")
            let location = Location(lat: start.lat, lon: start.lon)
            print(result)
            do {
                try repository.makeMemoMarkerAtFolders( model: result, location: location)
                
            } catch (let error) {
                realmError.value = error as? RealmManagerError
            }
        } else {
            guard memoSuccessOutPut.value != nil else { return }
            do {
                guard let modifyEnd else {return}
                print("###",modifyEnd)
                try repository.modifyMemo(structure: modifyEnd)
                if modifyEnd.modiFy{
                    if modifyEnd.markerImage != nil {
                        imagePag()
                    }
                }
            } catch (let error) {
                realmError.value = error as? RealmManagerError
            }
        }
    }
    
    // MARK: 이미지 저장 수정해야함
    func imagePag(){
        guard let modifyEnd = modifyEnd,
        let memoImage = modifyEnd.markerImage else { return }
        
        if !FileManagers.shard.saveMarkerZipImageForMemo(memoId: modifyEnd.locationMemoId, image: memoImage.resizingImage(targetSize: CGSize(width: 30, height: 30)) ) {
            
            realmError.value = RealmManagerError.canModifiMemo
        } else {
            if !FileManagers.shard.saveMarkerImageForMemo(memoId: modifyEnd.locationMemoId, image: memoImage) {
                
                realmError.value = RealmManagerError.canModifiMemo
            }
        }
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
                    let model = memoModifyOutstruct(memo: memo, folder: folder)
                    memoSuccessOutPut.value = model
                    modifyEnd = model
                }
            case .failure(let failure):
                print(failure.alertMessage)
            }
        }
    }
    
    
    private func textFiledTestster(string: String){
        if string.count >= 16 {
            
        }
    }
}


// location
/*repository.makeMemoAtFolder(folder: result.folder, memo: memo)*/
// memo
//        let memo = repository.makeMemoModel(addViewStruct: result, location: location)
// putInFolder
