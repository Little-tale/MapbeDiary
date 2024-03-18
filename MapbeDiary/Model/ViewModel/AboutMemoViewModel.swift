//
//  AboutMemoViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import Foundation

struct AboutMemoModel {
    var memoText: String?
    var iamgeData: [Data] = []
    var imageModify = false
    // New 새로 생성시에는 이모델
    var inputLoactionInfo: LocationMemo?
    var inputMemoMeodel: DetailMemo?
    var imageObject: [ImageObject]?
}

final class AboutMemoViewModel {
    
    //MARK: Input -------------
    let emptyModel: Observable<AboutMemoModel> =  Observable(AboutMemoModel(memoText: nil, iamgeData: []))
    
    let inputModel: Observable<AboutMemoModel?> = Observable(nil)
    
    let removeImage: Observable<IndexPath?> = Observable(nil)
    
    let inputImage: Observable<Data?> = Observable(nil)
    
    // Modify
    //let inputMemoInfo: Observable<DetailMemo?> = Observable(nil)

    let saveInput: Observable<Void?> = Observable(nil)
    
    let removiewInput: Observable<Void?> = Observable(nil)
    
    //MARK: Output =============
   
    let repoErrorPut: Observable<RealmManagerError?> = Observable(nil)
    
    let fileErrorPut: Observable<fileManagerError?> = Observable(nil)
    
    let deletButtonHidden: Observable<Bool?> = Observable(nil)
    
    let dismissOutPut: Observable<Void?> = Observable(nil)
    
    let successSave: Observable<Void?> = Observable(nil)
    
    // static
    let repository = RealmRepository()
    
    var maxImageCount = 3
    
    init(){
        print(repository.printURL())
        // input -> EnptyModel 전달
        inputModel.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            proceccing(model)
        }
        // 새로 생길 상황의 로직
        saveInput.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else  { return }
            saveButtonAction()
        }
        // 전체 지우기
        removiewInput.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            removeAciton()
        }
        // 단일 이미지 제거
        removeImage.bind { [weak self] indexPath in
            guard let self else { return }
            guard let indexPath else { return }
            removeJustImage(indexPath)
        }
        inputImage.bind { [weak self] data in
            guard let self else { return }
            guard let data else { return }
            onlyOneSaveImage(data: data)
        }
    }
    // MARK: 전뷰에 결정에 따라 로직 분리 일단 엠티모델에 넣기
    private func proceccing(_ model: AboutMemoModel) {
       var proceccingModel = model
        dump(model.inputMemoMeodel?.imagePaths)
        if let detailMemoModel = model.inputMemoMeodel {
            if let imageOj = model.inputMemoMeodel?.imagePaths {
                let before = Array(imageOj)
                proceccingModel.imageObject = before
                
                let beforeData = before.map { $0.id.stringValue }
                let results = FileManagers.shard.findDetailImageData(detailID: detailMemoModel.id.stringValue, imageIds: beforeData)
                
                switch results {
                case .success(let success):
                    proceccingModel.iamgeData = success
                case .failure(let failure):
                    fileErrorPut.value = failure
                }
            }
        }
        emptyModel.value = proceccingModel
        deletButtonHidden.value = proceccingModel.inputMemoMeodel != nil ? true : false 
    }
    
    private func saveButtonAction() {
        print("location")
        
        let model = emptyModel.value
        
        guard let text = model.memoText else {
            return // 텍스트는 필수 라고 하기!
        }
        
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            return // 테스트는 필수라고 하기!
        }
        print("model")
        
        if let location = inputModel.value?.inputLoactionInfo,
           inputModel.value?.inputMemoMeodel == nil {
            let results = repository.makeDetailMemo(model, location)
            switch results {
            case .success (let success):
                print("#### 여기 아닌가???")
                for image in model.iamgeData {
                    
                    let results = repository.makeDetailMemoImage(dtMemo: success, imageData:image)
                    
                    switch results {
                    case .success:
                        break
                    case .failure(let failure):
                        repoErrorPut.value = failure
                        return
                    }
                }
                dismissOutPut.value = ()
            case .failure(let error):
                repoErrorPut.value = error
            }
        } else if inputModel.value?.inputLoactionInfo != nil,
                inputModel.value?.inputMemoMeodel != nil{
            // 수정시 ......
            
            let results = repository.updateDetailMemo(memoModel: emptyModel.value)

            switch results {
            case .success(_):
                updateImageObject()
            case .failure(let failure):
                print("여기인가?")
                repoErrorPut.value = failure
                return
            }
           
        }
        NotificationCenter.default.post(name: .didSaveActionDetailMemo, object: nil)
    }
    
    // MARK: 로직 변경해야함.
    private func removeJustImage(_ indexPath: IndexPath){
        guard (emptyModel.value.imageObject?[indexPath.item]) != nil else {
            return
        }

        emptyModel.value.imageObject?.remove(at: indexPath.item)
        emptyModel.value.iamgeData.remove(at: indexPath.item)
        dump(emptyModel.value)
        let test = emptyModel.value.imageObject
        print("^^^^",test?.forEach({ $0.id.stringValue }))
    }
    
    private func updateImageObject(){
        guard let detailMemo = emptyModel.value.inputMemoMeodel else { return }
        guard let imageModel = emptyModel.value.imageObject else { return  dismissOutPut.value = () }
        
        let imageData = emptyModel.value.iamgeData
        
        let results = repository.removeAllImageObjects(detail: detailMemo)
        
        if case .failure = results {
            repoErrorPut.value = .cantModifyMemo
        }
        
        imageData.forEach { data in
            let result = repository.makeDetailMemoImage(dtMemo: detailMemo, imageData: data)
            if case .failure(let failure) = results {
                repoErrorPut.value = failure
                return
            }
        }
        dismissOutPut.value = ()
    }
    
    
    /*
     print(imageModel)
     repository.updateDetailMemoImage(dtMemo: detailMemo, imageObjects:imageModel, imageData: imageData) { [weak self] result in
         switch result {
         case .success(let success):
             print(success)
             
             self?.dismissOutPut.value = ()
         case .failure(let failure):
             print(failure)
         }
     }
     */
    // 1. 일단 렘에 반영 -> 이러면 뒤로가면 사고임
//        let results = repository.removeImageObjectFromModify(imageObject)
//        switch results {
//        case .success:
//            break
//        case .failure(let failure):
//            repoErrorPut.value = failure
//        }
    //        repository.deleteImageAndImgObject(imgOJ) { [weak self] results in
    //            guard let self else { return }
    //            switch results {
    //            case .success:
    //                inputModel.value = inputModel.value
    //            case .failure(let failure):
    //                repoErrorPut.value = failure
    //            }
    //        }
    
    private func removeAciton(){
        guard let detail = inputModel.value?.inputMemoMeodel else {
            print("지우기 실패")
            return
        }
                repository.deleteDetailMemo(detail) { [weak self] results in
                    guard let self else { return }
                    switch results {
                    case .success(_):
                        successSave.value = ()
                    case .failure(let failure):
                        repoErrorPut.value = failure
                    }
                }
        print( emptyModel.value.imageObject ?? "")
    }
    
    
    private func onlyOneSaveImage(data: Data){
        if let input = emptyModel.value.inputMemoMeodel {
            let result =  repository.makeDetailMemoImage(dtMemo: input, imageData: data)
            
            switch result {
            case .success(_):
                inputModel.value = inputModel.value
            case .failure(let failure):
                repoErrorPut.value = failure
            }
        }
    }
    
}

/*
 if model.imageModify {
     
     let removeResults = repository.removeAllImageObjects(detail: memo)
     switch removeResults {
     case .success:
         break
     case .failure(let failure):
         repoErrorPut.value = .cantModifyMemo
     }
     
     for image in model.iamgeData {
         let results = repository.makeDetailMemoImage(dtMemo: memo, imageData:image)
         switch results {
         case .success:
             break
         case .failure(let failure):
             repoErrorPut.value = failure
         }
     }
 }
 */
