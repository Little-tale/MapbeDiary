//
//  AddViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

struct addViewStruct {
    let lat: String
    let lon: String
    var folder: Folder
    
    init(lat: String, lon: String, folder: Folder) {
        self.lat = lat
        self.lon = lon
        self.folder = folder
    }
}
struct addViewOutStruct {
    var title: String
    let titlePlacHolder: String
    var content: String
    var folder: Folder
    
    init(title: String?, titlePlacHolder: String?, folder: Folder) {
        self.title = title ?? AddViewSection.defaultTitle
        self.titlePlacHolder = titlePlacHolder ?? "Add_title_text_fileld_text".localized
        self.folder = folder
        self.content = ""
    }
}

class AddViewModel {
    // ------- In Put ------
    let coordinateTrigger: Observable<(addViewStruct)?> = Observable(nil)
    
    let changeFolder: Observable<Folder?> = Observable(nil)
    
    let saveButtonTrigger: Observable<Void?> = Observable(nil)
    
    // ------- Out Put -----
    let urlSuccessOutPut: Observable<addViewOutStruct?> = Observable(nil)
    
    let urlErrorOutPut: Observable<URLSessionManagerError?> = Observable(nil)
    
    let realmError: Observable<RealmManagerError?> = Observable(nil)
    
    // ------- Static -------
    private let repository = RealmRepository()
    var titleName = String()
 
    
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
        //print("출력: ",success.documents)
        urlSuccessOutPut.value = addViewOutStruct(title:AddViewSection.defaultTitle,titlePlacHolder: model.documents.first?.roadAddress.addressName, folder: folder)
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
        // location
        let location = Location(lat: start.lat, lon: start.lon)
        // memo
        let memo = repository.makeMemoModel(title: result.title, contents: result.content, location: location)
        // putInFolder
        do {
            try repository.makeMemoAtFolder(folder: result.folder, memo: memo)
        } catch (let error) {
            realmError.value = error as? RealmManagerError
        }
    }
}
