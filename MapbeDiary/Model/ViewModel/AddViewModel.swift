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
    
    // ------- Out Put -----
    let urlSuccessOutPut: Observable<addViewOutStruct?> = Observable(nil)
    
    let saveButtonOutPutImage: Observable<String?> = Observable(nil)
    
    let urlErrorOutPut: Observable<URLSessionManagerError?> = Observable(nil)
    
    let realmError: Observable<RealmManagerError?> = Observable(nil)
    
    // ------- Static -------
    let repository = RealmRepository()
    var titleName = String()
    var searchTitle: String?
    
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
        guard let result = urlSuccessOutPut.value else { return }
        
        let location = Location(lat: start.lat, lon: start.lon)
        print(result)
        do {
            try repository.makeMemoAtFolder(folder: result.folder, model: result, location: location)
            
        } catch (let error) {
            realmError.value = error as? RealmManagerError
        }
    }
}


// location
/*repository.makeMemoAtFolder(folder: result.folder, memo: memo)*/
// memo
//        let memo = repository.makeMemoModel(addViewStruct: result, location: location)
// putInFolder
