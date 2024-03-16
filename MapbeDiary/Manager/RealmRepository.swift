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
    
    func deleteAllImageFromLocationMemo(memoId: ObjectId) throws {
        let memoIdString = memoId.stringValue
        // 1. 마커 이미지 제거
        if !FileManagers.shard.removeMarkerImageAtMemo(memoIdString: memoIdString){
            throw RealmManagerError.cantDeleteImage
        }

        // 2. 메모 제거
        let memo = realm.objects(locationMemoModel).where { $0.id == memoId }.first
        guard let memo else { throw RealmManagerError.cantDeleteMemo }
       
        // 3. 메모 제거
        do {
            try realm.write {
                realm.delete(memo)
            }
        } catch {
            throw RealmManagerError.cantDeleteMemo
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