//
//  AddViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation



class AddViewModel {
    // ------- In Put ------
    let coordinateTrigger: Observable<(addViewStruct)?> = Observable(nil)
    //let coordinateModifyTrriger: Observable?
    
    let changeFolder: Observable<Folder?> = Observable(nil)
    
    let saveButtonTrigger: Observable<Void?> = Observable(nil)
    
    // MARK: 수정시 Input ------
    let modifyTrigger: Observable<String?> = Observable(nil)
    
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
    var modifyEnd : memoModifyOutstruct?
    
    init(){
        coordinateTrigger.bind {[weak self] coordi in
            guard let self else {return}
            guard let coordi else {return}
            apiRequest(lat: coordi.lat, lon: coordi.lon, folder: coordi.folder)
            print("@@!!",coordi.folder)
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
    
    private func apiRequest(lat: String, lon: String, folder: Folder){
        print(lat, lon)
        URLSessionManager.shared.fetch(type: KaKakaoCordinateModel.self, api: KakaoApiModel.cordinate(x: lon, y: lat)) {
            [weak self] results in
            guard let self else { return }
            switch results {
            case .success(let success):
                
                proccing(model:success, folder: folder)
            case .failure(let fail):
                print("@@fail 통신실패")
                urlErrorOutPut.value = fail
                print(fail.errorMessage)
            }
        }
    }
    
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
        guard let start = coordinateTrigger.value else { return }
        
        if let result = urlSuccessOutPut.value {
            print("마커",result.memoImage ?? "")
            let location = Location(lat: start.lat, lon: start.lon)
            print(result)
            do {
                try repository.makeMemoMarkerAtFolders( model: result, location: location)
                
            } catch (let error) {
                realmError.value = error as? RealmManagerError
            }
        } else {
            guard let modify = memoSuccessOutPut.value else { return }
            do {
                try repository.modifyMemo(structure: modify)
            } catch (let error) {
                realmError.value = error as? RealmManagerError
            }
        }
        
    }
    // MARK: 메모스트링 아이디를 통해 메모를 찾아옵니다.
    private func findMemo(memoId: String){
        repository.findId(IdString: memoId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                if let memo = repository.findMemo(ojID: success),
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
}


// location
/*repository.makeMemoAtFolder(folder: result.folder, memo: memo)*/
// memo
//        let memo = repository.makeMemoModel(addViewStruct: result, location: location)
// putInFolder
