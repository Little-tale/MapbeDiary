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
    let memoModel = Memo.self
    let locationModel = Location.self
    
    // MARK: 단순히 도큐먼트 위치를 호출하는 메서드
    func printURL(){
        print(realm.configuration.fileURL ?? "Error")
    }
    
    // MARK:  --------
    
    // MARK: folder를 생성하는 메서드 V ->
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
    // MARK: 메모를 만들어 드립니다. V
    func makeMemoModel(title: String, contents: String?, location: Location) -> Memo {
        return Memo(title: title, location: location, contents: contents)
//        do {
//            try realm.write {
//                realm.add(Memo(title: title, location: location, contents: contents))
//            }
//        } catch {
//            throw RealmManagerError.canMakeMemo
//        }
    }
    
  
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
    func findMemo(date: Date) -> Memo?{
        let findMemo = realm.objects(memoModel).where { $0.regdate == date }
        let memo = findMemo.first
        return memo
    }
    
    
    
    // MARK: 폴더를 먼저 만들었다면 이후에 메모를 넣습니다.
    /// 폴더가 있고 Memo 객체가 있어야 폴더에 추가해드립니다. 중복 방지 해놓았습니다.
    func makeMemoAtFolder(folder: Folder, memo: Memo) throws {
        do {
            try realm.write {
                let isMemo = folder.memolist.contains(memo)
                if !isMemo {
                    folder.memolist.append(memo)
                } else { print("중복이 존재해 안해요!") }
            }
        } catch {
            throw RealmManagerError.cantAddMemoInFolder
        }
        
    }
    // MARK: ------------- Create -------------
    
    // MARK: 모든 메모를 가져옵니다. V
    /// 모든 메모를 가져옵니다.
    func findAllMemo() -> Results<Memo>{
        return realm.objects(Memo.self)
    }
    
    // MARK: 모든 폴더를 가져옵니다. V
    /// 모든 폴더를 가져옵니다.
    func findAllFolder() -> Results<Folder>{
        return realm.objects(Folder.self).sorted(byKeyPath: "index", ascending: true)
    }
    
    // MARK: 모든 메모를 가져옵니다. 단 Array 입니다.
    /// 모든 메모를 가져옵니다. 단 Array 입니다.
    func findAllMemoArray() -> [Memo] {
        let data = findAllMemo()
        return Array(data)
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
                realm.create(memoModel, value: value, update: .modified)
            }
        } catch {
            throw RealmManagerError.canModifiMemo
        }
    }
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
                if let memo = realm.object(ofType: Memo.self, forPrimaryKey: memoId) {
                    memo.imagePaths.append(imageObject)
                }
            }
        } catch {
            throw RealmManagerError.cantAddImage
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
    
    // MARK: -------------- Remove ---------------------
    
    // MARK: 정렬된 데이터 기준으로 삭제후 정렬되게 구성하기
    func removeFolderAt(IndexPath: Int, results: @escaping (Result<Void, RealmManagerError>) -> Void ) {
        let AllFolder = findAllFolderArray()
        print(AllFolder)
        
        let select = AllFolder[IndexPath]
        do {
            try realm.write {
                if let object = realm.objects(folderModel).where ({ $0.id == select.id}).first{
                    realm.delete(object.memolist)
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
                let data = realm.objects(memoModel).where { $0.id == id }
                realm.delete(data)
            }
        } catch {
            throw RealmManagerError.cantDeleteMemo
        }
    }
    // MARK: 메모 자체를 넘기면 메모를 제거합니다.
    func removeMemo(memo: Memo) throws{
        do{
            try realm.write {
                realm.delete(memo)
            }
        } catch{
            throw RealmManagerError.cantDeleteMemo
        }
    }
    
    func deleteImageFromMemo(memoId: ObjectId, imageName: String) throws {
        
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
    
    
}
