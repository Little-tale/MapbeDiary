//
//  RealmManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import RealmSwift
import UIKit



//MARK: RalmRepository
class RealmRepository {
    // 레포지터리 패턴
    let realm = try! Realm()
    let folderModel = Folder.self
    let locationMemoModel = LocationMemo.self
    let locationModel = Location.self
    let detailMemoModel = DetailMemo.self
    let imageModel = ImageObject.self
    
    // MARK: 단순히 도큐먼트 위치를 호출하는 메서드
    func printURL(){
        print(realm.configuration.fileURL ?? "Error")
    }
    
    // MARK:  --------
    
    // MARK: folder를 생성하는 메서드 V -> 2차 테이블구조 V
    func makeFolder(folderName: String) throws {
        var index = 0
        if !realm.objects(folderModel).isEmpty {
            let last = realm.objects(folderModel).sorted(byKeyPath: "index", ascending: false)[0]
            index = last.index + 1
        }
        do{
            try realm.write {
                realm.add(Folder(folderName: folderName, index: index))
            }
        }catch{
            throw RealmManagerError.canMakeFolder
        }
    }
    
    func makeLocation(title: String,lat: String, long: String) {
        
    }
    // MARK: 어떤 타입이든 보내기
    func fetchItems<T: Object>(type: T.Type) -> Results<T> {
        let items = realm.objects(type.self)
        return items
    }
    
    // MARK: 메모를 만들어 드립니다. V
    func makeMemoModel(title: String, contents: String?, location: Location, phoneNum: String?) -> LocationMemo {
        return LocationMemo(title: title, location: location, contents: contents, phoneNumber: phoneNum)
    }
    
    // MARK: 메모를 진짜 만들어드립니다...>!
    func makeMemoModel(addViewStruct: addViewOutStruct, location: Location) throws -> LocationMemo?  {
        var memo: LocationMemo?
        do {
            try realm.write {
                memo = realm.create(LocationMemo.self, value: [
                    "title": addViewStruct.title,
                    "location": location,
                    "contents": addViewStruct.content,
                    "phoneNumber": addViewStruct.phoneNumber ?? ""
                ])
            }
        } catch {
            throw RealmManagerError.canMakeMemo
        }
        return memo
    }
    // MARK: 메모 수정 버전
    func modifyMemo(structure: memoModifyOutstruct) throws {
        do {
            try realm.write {
                do {
                  let id = try ObjectId(string: structure.locationMemoId)
                    realm.create(LocationMemo.self, value: [
                        "id": id,
                        "title": structure.title,
                        "contents": structure.content ?? "",
                        "phoneNumber": structure.phoneNumber ?? ""
                    ], update: .modified)
                } catch {
                    throw RealmManagerError.cantModifyMemo
                }
            }
        } catch {
            throw RealmManagerError.cantModifyMemo
        }
    }
    
    // MARK: LocationMemo를 통해 DetailMemo를 가져오거나 만들어 옵니다
//    func findLocationMemoForDetailMemo(location: LocationMemo){
//        
//    }
  
    private func reSortedOfFolder(handler: @escaping(Result<Void,RealmManagerError>) -> Void) throws {
        let allFolder = realm.objects(folderModel).sorted(byKeyPath: "index", ascending: true)
        
        allFolder.enumerated().forEach {[weak self] index, value in
            guard let self else {return}
            do {
                try realm.write {
                    value.index = index
                }
                handler(.success( () ))
            } catch {
                handler(.failure( RealmManagerError.cantSortedOfFolder))
            }
        }
    }
    
    // MARK: IndexPath or index 기반 폴더 찾기
    func findFolderAt(indexPathNum: Int){
        
    }
    
    // MARK: 메모 날짜를 통해 메모를 찾습니다.
    func findLocationMemo(date: Date) -> LocationMemo?{
        let findMemo = realm.objects(locationMemoModel).where { $0.regdate == date }
        let memo = findMemo.first
        return memo
    }
    func findFirstLocationMemo() -> LocationMemo? {
        let first = realm.objects(locationMemoModel).first
        return first
    }
    
    // MARK: ID를 통해 메모를 찾습니다.
    func findLocationMemo(ojID: ObjectId) -> LocationMemo? {
        let findMemo = realm.objects(locationMemoModel).where { $0.id == ojID }
        let memo = findMemo.first
        return memo
    }
    
    func findLocationMemo(ojidString: String, compite: @escaping (Result<LocationMemo, RealmManagerError>) -> Void){
        do {
            let objectId =  try ObjectId(string: ojidString)
            let memo = findLocationMemo(ojID: objectId)
            guard let memo else {
                compite(.failure(.cantFindLocationMemo))
                return
            }
            compite(.success(memo))
        } catch {
            compite(.failure(.cantFindObjectId))
        }
    }
    
    // MARK: 메모를 통해 속한 폴더를 찾습니다.
    func findMemoAtFolder(memo: LocationMemo) -> Folder?{
        let findFoler = memo.parents.first
        return findFoler
    }
    
    // MARK: 폴더를 통해 메모를 찾습니다.
    /// 폴더를 통해 메모를 찾습니다.
    func findLocationMemoForFolder(folder: Folder) -> [LocationMemo] {
        let locations = Array(folder.LocationMemo)
        return locations
    }
    
    
    // MARK: 폴더를 먼저 만들었다면 이후에 메모를 넣습니다.
    /// 폴더가 있고 Memo 객체가 있어야 폴더에 추가해드립니다. 중복 방지 해놓았습니다.
    func makeMemoAtFolder(folder: Folder, memo: LocationMemo) throws {
        do {
            try realm.write {
                let isMemo = folder.LocationMemo.contains(memo)
                if !isMemo {
                    folder.LocationMemo.append(memo)
                } else { print("중복이 존재해 안해요!") }
            }
        } catch {
            throw RealmManagerError.cantAddMemoInFolder
        }
    }

    
    func makeMemoMarkerAtFolders( model: addViewOutStruct, location: Location) throws {
        let memo = try? makeMemoModel(addViewStruct: model, location: location)
        guard let memo else { return }
        
        if let image = model.memoImage {
            if FileManagers.shard.saveMarkerImageForMemo(memoId: memo.id.stringValue, image: image) {
                print("makeMemoMarkerAtFolders",image)
                let imageZip = image.resizingImage(targetSize: CGSize(width: 40, height: 30))
                if FileManagers.shard.saveMarkerZipImageForMemo(memoId: memo.id.stringValue, image: imageZip) {
                } else {
                    throw RealmManagerError.cantAddImage
                }
            }else {
                throw RealmManagerError.cantAddImage
            }
        }
        let folder = model.folder
        do {
            try realm.write {
                folder.LocationMemo.append(memo)
            }
        } catch {
            throw RealmManagerError.cantAddMemoInFolder
        }
    }


    
    
    // MARK: ------------- Create -------------
    
    // MARK: 모든 메모를 가져옵니다. V
    /// 모든 메모를 가져옵니다.
    func findAllMemo() -> Results<LocationMemo>{
        return realm.objects(LocationMemo.self)
    }
    
    // MARK: 모든 폴더를 가져옵니다. V
    /// 모든 폴더를 가져옵니다.
    func findAllFolder() -> Results<Folder>{
        return realm.objects(Folder.self).sorted(byKeyPath: "index", ascending: true)
    }
    
    // MARK: 모든 메모를 가져옵니다. 단 Array 입니다.
    /// 모든 메모를 가져옵니다. 단 Array 입니다.
    func findAllMemoArray() -> [LocationMemo] {
        let data = findAllMemo()
        return Array(data)
    }
    func findAllMemoAtFolder(folder: Folder) -> [LocationMemo] {
        let folderList = folder.LocationMemo
        let memos = Array(folderList)
        return memos
    }
    
    // MARK: 모든 폴더를 가져옵니다. 단 Array 입니다.
    /// 모든 폴더를 가져옵니다. 단 Array 입니다.
    func findAllFolderArray() -> [Folder] {
        let data = findAllFolder()
        return Array(data)
    }
    // MARK: 메모를 수정합니다.
    /// Memo를 수정합니다.
    func modifyMemoId(memoId: ObjectId, title: String?, contents: String?, detaile: String?, phoneNum: String?) throws{
        
        var value: [String: Any] = ["id": memoId]
            if let newTitle = title { value["title"] = newTitle }
            if let newContents = contents { value["contents"] = newContents }
            if let newDetailContents = detaile { value["detailContents"] = newDetailContents }
            if let newPhoneNumber = phoneNum { value["phoneNumber"] = newPhoneNumber }
            
        do {
            try realm.write {
                realm.create(locationMemoModel, value: value, update: .modified)
            }
        } catch {
            throw RealmManagerError.canModifiMemo
        }
    }
    
    func findId(IdString: String, complite: @escaping (Result< ObjectId, RealmManagerError>) -> Void ){
        do {
            let idObject = try ObjectId(string: IdString)
            complite(.success(idObject))
        } catch {
            complite(.failure(.cantFindObjectId))
        }
    }
    
   
    
    // MARK: 메모 아이디 기준으로 폴더 생성
    func getFolderPathForMemoId(memoId: ObjectId) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let folderPath = documentsDirectory.appendingPathComponent("\(memoId)")
        
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            try? FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false, attributes: nil)
        }
        return folderPath
    }
    
    // MARK: 디테일 메모를 생성하면서 로케이션 메모에 등록합니다.
    func makeDetailMemo(_ model: AboutMemoModel,_ location: LocationMemo) -> Result<DetailMemo,RealmManagerError> {
        guard let text = model.memoText else { return .failure(.cantMakeDetailMemo) }
        
        let memoModel = DetailMemo(detailContents: text, modifyDate: nil)
        do { 
            try realm.write {
                realm.add(memoModel)
            }
            
            try realm.write {
                if location.detailMemos.contains(memoModel){
                    return
                }
                location.detailMemos.append(memoModel)
            }
        } catch {
            return .failure(.cantMakeDetailMemo)
        }
        return .success( memoModel )
    }
    
    // MARK: 디테일 메모 이미지를 저장합니다.
    /// 디테일 메모 이미지를 저장합니다. 반복문이 필요합니다.
    func makeDetailMemoImage(dtMemo: DetailMemo, imageData: Data) -> Result<Void,RealmManagerError>{
        var index = 0
        
        if let lastImage = dtMemo.imagePaths.sorted(byKeyPath: "orderIndex", ascending: false).first {
              index = lastImage.orderIndex + 1
        }
        
        if index >= 3 {
            return .failure(.cantAddImage)
        }
        
        let imageObject = ImageObject(index: index)

        do {
            try realm.write {
                realm.add(imageObject)
                dtMemo.imagePaths.append(imageObject)
            }
        } catch {
            return .failure(.cantAddImage)
        }
        
        if !FileManagers.shard.createMemoImage(
            detailMemoId: dtMemo.id.stringValue,
            imgOJId: imageObject.id.stringValue,
            data: imageData
        ) {
            return .failure(.cantAddImage)
        }
        
        return .success(())
    }
    
    ///  디테일 이미지 리스트 가져오기
    func findDetailImagesList(detail: DetailMemo) -> [ImageObject] {
        return Array(detail.imagePaths)
    }
    
    /// 디테일 메모를 업데이트
    func updateDetailMemo(memoModel: AboutMemoModel) -> Result<Void,RealmManagerError> {
        guard let memo = memoModel.inputMemoMeodel,
              let text = memoModel.memoText else {
            print("error\(memoModel.inputMemoMeodel), \(memoModel.memoText)")
            return .failure(.cantModifyMemo)
        }
        // 이미지는 알아서 업데이트 되게 해버림 즉 텍스트만 업데이트하면 된다.!
        do {
            try realm.write {
                let value: [String: Any] = [
                    "id": memo.id,
                    "detailContents": text
                ]
                realm.create(detailMemoModel, value: value, update: .modified)
            }
        } catch {
            print("여기임?")
            return .failure(.canModifiMemo)
        }
        return .success(())
    }
    
    // MARK: -------------- Remove ---------------------
    
    // MARK: 정렬된 데이터 기준으로 삭제후 정렬되게 구성하기
    func removeFolderAt(IndexPath: Int, results: @escaping (Result<Void, RealmManagerError>) -> Void ) {
        let AllFolder = findAllFolderArray()
        print(AllFolder)
        
        let select = AllFolder[IndexPath]
        do {
            try realm.write {
                if let object = realm.objects(folderModel).where ({ $0.id == select.id}).first{
                    realm.delete(object.LocationMemo)
                    realm.delete(object)
                }
            }
        } catch {
            results(.failure( RealmManagerError.cantDeleteOfFolder))
        }
        do {
            try reSortedOfFolder { [weak self] result in
                guard self != nil else {return}
                switch result {
                case .success:
                    return
                case .failure(let failure):
                    results(.failure(failure)) //  failure
                }
            }
        } catch {
            results(.failure(RealmManagerError.cantDeleteOfFolder))
            
        }
    }
    // MARK: ID를 통해 Memo를 지웁니다.
    /// ID를 통해 메모를 지워드립니다.
    func removeMemoID(id: ObjectId) throws{
        do {
            try realm.write {
                let data = realm.objects(locationMemoModel).where { $0.id == id }
                realm.delete(data)
            }
        } catch {
            throw RealmManagerError.cantDeleteMemo
        }
    }
    // MARK: 메모 자체를 넘기면 메모를 제거합니다.
    func removeMemo(memo: LocationMemo) throws{
        do{
            try realm.write {
                realm.delete(memo)
            }
        } catch{
            throw RealmManagerError.cantDeleteMemo
        }
    }
    
    func deleteImageFromMemoAt(memoId: ObjectId, imageName: String) throws {
        
        let imagePath = getFolderPathForMemoId(memoId: memoId).appendingPathComponent(imageName)
        
        // 파일 시스템에서 이미지 삭제
        try? FileManager.default.removeItem(at: imagePath)
        
        // Realm에서 ImageObject 삭제
        do {
            let imageObject = realm.objects(ImageObject.self).where { $0.imagename == imageName }.first
            if let imageObject {
                try realm.write {
                    realm.delete(imageObject)
                }
            }
        } catch {
            throw RealmManagerError.cantDeleteImage
        }
    }
    
    private func deleteAllImageFromLocationMemo(memoId: ObjectId, compltion: (Result<Void, RealmManagerError>) -> Void) {
        let memoIdString = memoId.stringValue
        // 1. 마커 이미지 제거
        if !FileManagers.shard.removeMarkerImageAtMemo(memoIdString: memoIdString){
            compltion(.failure(.cantDeleteImage))
        }

        // 2. 메모 제거
        let memo = realm.objects(locationMemoModel).where { $0.id == memoId }.first
        guard let memo else {
            compltion(.failure(.cantDeleteMemo))
            return
        }

        // 3. 메모 제거
        do {
            try realm.write {
                realm.delete(memo)
            }
        } catch {
            compltion(.failure(.cantDeleteMemo))
        }
        compltion(.success(()))
    }
    /// 디테일 메모에 있는 이미지들을 지웁니다. + 디테일도 지웁니다.
    func removeAllImageObjects(detail: DetailMemo) -> Result<Void,RealmManagerError> {
        let images = findDetailImagesList(detail: detail)
        do {
            for image in images {
                try realm.write {
                    realm.delete(image)
                }
            }
        } catch {
            return .failure(.cantDeleteImage)
        }
        return .success(())
    }
    
    /// 디테일메모를 지웁니다.
    func removeDetail(_ detail: DetailMemo) -> Result<Void,RealmManagerError> {
        do {
            try realm.write {
                realm.delete(detail)
            }
        } catch {
            return .failure(.cantDeleteDetailMemo)
        }
        return .success(())
    }
    
    
    func removeImageObject(_ image: ImageObject) -> Result<Void,RealmManagerError> {
        // 1. 인덱스가 무엇이지 알아내기
        // 2. 객체를 지우기
        // 3. 재정렬 해주기
        let index = image.orderIndex
        do {
            try realm.write {
                realm.delete(image)
                let datas = realm.objects(imageModel).where { $0.orderIndex > index }
                for data in datas {
                    data.orderIndex -= 1
                }
            }
        } catch {
            return .failure(.cantDeleteImage)
        }
        return .success(())
    }
    
    func removeImageObjectFromModify(_ image: ImageObject) -> Result<Void,RealmManagerError>{
        let realmImage = realm.objects(imageModel).where{ $0.id == image.id }
        
        let index = image.orderIndex
        do {
            try realm.write {
                realm.delete(image)
                let datas = realm.objects(imageModel).where { $0.orderIndex > index }
                for data in datas {
                    data.orderIndex -= 1
                }
            }
        } catch {
            return .failure(.cantDeleteImage)
        }
        return .success(())
    }
    
    // MARK: DetailMemo를 제거할때
    func deleteDetailMemo(_ detail: DetailMemo, complition: @escaping(Result<Void, RealmManagerError>) -> Void ){
        
        // 0. 이미지 리스트 가져오기
        let detailImages = findDetailImagesList(detail: detail)
        
        // 1. 이미지 먼저 지우기 시도
        let imageIdString = detailImages.map { $0.id.stringValue }
        
        let results = FileManagers.shard.removeDetailImageList(detailId: detail.id.stringValue, imageIds: Array(imageIdString))
        
        switch results {
        case .success():
            break
        case .failure(_):
            complition(.failure(.cantDeleteImage))
        }
        
        // 2. 이미지 테이블 지우기 시도
        let removeResults = removeAllImageObjects(detail: detail)
        
        switch removeResults {
        case .success(_):
            break
        case .failure(let failure):
            complition(.failure(failure))
        }
        
        // 3. detail 삭제
        let detailRemove = removeDetail(detail)
        switch detailRemove {
        case .success(let success):
            complition(.success(success))
        case .failure(let failure):
            complition(.failure(failure))
        }
    }
    
    // MARK: ImageObject(이미지파일도) 만 제거할때
    func deleteImageAndImgObject(_ imgOJ: ImageObject, complite: @escaping(Result<Void,RealmManagerError>) -> Void){
        
        let dtail = imgOJ.parents.first
        guard let dtail else { return }
        // 이미지 먼저 제거
        let results = FileManagers.shard.removeDetailImage(detailId: dtail.id.stringValue, imageId: imgOJ.id.stringValue)
        switch results {
        case .success(_):
            let imageResults = removeImageObject(imgOJ)
            switch imageResults {
            case .success(let success):
                complite(.success(success))
            case .failure(let failure):
                complite(.failure(failure))
            }
        case .failure(_):
            complite(.failure(.cantDeleteImage))
        }
    }
    
    func deleteLocationMemo(_ location: LocationMemo, complite: @escaping(Result<Void,RealmManagerError>) -> Void){
        // 너무 많은 작업이 있을것 같음으로
        let group = DispatchGroup()
        var firstError: RealmManagerError?
        
        // DetailMemo -> 이미지까지 다 지우는걸 반복
        for detail in location.detailMemos {
            group.enter()
            deleteDetailMemo(detail) { [weak self] result in
                guard let self else { complite(.failure(.cantDeleteLocationMemo))
                    return
                }
                
                if case .failure(let failure) = result,
                   firstError == nil {
                    firstError = failure
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            if let firstError {
                complite(.failure(firstError))
            }
            
            self.deleteAllImageFromLocationMemo(memoId: location.id) { result in
                switch result {
                case .success(let success):
                    complite(.success(success))
                case .failure(let failure):
                    complite(.failure(failure))
                }
            }
        }
    }
    
    
}


/*
 let memoImageList = Array(memo.imagePaths)
 
 memoImageList.forEach { [weak self] imageObject in
     guard self != nil else { return }
     if !FileManagers.shard.removeImageListAtMemo(memoidString: memoIdString, ImageIdString: imageObject.id.stringValue) {
     }
 }
 */

// MARK: 뭔가 꼬임 이거 재수정 바람 목적과 맞지 않음
//    func makeMemoAtFolder(folder: Folder, model: addViewOutStruct, location: Location) throws {
//        let memo = try? makeMemoModel(addViewStruct: model, location: location)
//        guard let memo else { return }
//
//        if let image = model.memoImage {
//            let imageUUID = UUID().uuidString
//            let imagePath = getFolderPathForMemoId(memoId: memo.id).appendingPathComponent(imageUUID)
//
//            // UIImage를 파일 시스템에 저장
//            if let imageData = image.jpegData(compressionQuality: 0.8) {
//                do {
//                    try imageData.write(to: imagePath)
//                    let imageObject = ImageObject(imagename: imageUUID, index: memo.imagePaths.count)
//                    do {
//                        try realm.write {
//                            memo.imagePaths.append(imageObject)
//                        }
//                    } catch {
//                        throw RealmManagerError.cantAddImage
//                    }
//                } catch {
//                    throw RealmManagerError.cantAddImage
//                }
//            }
//        }
//        do {
//            try realm.write {
//                folder.memolist.append(memo)
//            }
//        } catch {
//            throw RealmManagerError.cantAddMemoInFolder
//        }
//    }

/*
 // MARK: 이미지 추가
 /// 메모 아이디 와 UIImage를 통해 이미지를 저장합니다.
 func addImageToMemo(memoId: ObjectId, image: UIImage, imageName: String) throws {
     let imagePath = getFolderPathForMemoId(memoId: memoId).appendingPathComponent(imageName)
     
     // UIImage를 파일 시스템에 저장
     if let imageData = image.jpegData(compressionQuality: 0.8) {
         try? imageData.write(to: imagePath)
     }
     
     // Realm에 ImageObject 추가
     do {
         try realm.write {
             let imageObject = ImageObject()
             imageObject.imagename = imageName
             
             // orderIndex와 다른 속성 설정
             if let memo = realm.object(ofType: LocationMemo.self, forPrimaryKey: memoId) {
                 memo.imagePaths.append(imageObject)
             }
         }
     } catch {
         throw RealmManagerError.cantAddImage
     }
 }
 */
