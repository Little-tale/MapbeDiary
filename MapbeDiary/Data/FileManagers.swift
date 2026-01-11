//
//  FileManagers.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit.UIImage

enum fileManagerError: Error{
    case cantFindDocuments
    case cantFindImages
    case cantRemoveImages
    
    var message: String {
        switch self {
        case .cantFindDocuments:
            return "사용자님의 데이터를 찾을수가 없습니다."
        case .cantFindImages:
            return "이미지들을 찾을수가 없습니다."
        case .cantRemoveImages:
            return "이미지를 지울수 없습니다."
        }
    }
}


final class FileManagers {
    private init () {}
    static let shard = FileManagers()
    
    private let fileManager = FileManager.default
    
    /// 메모 이미지를 읽어옵니다 사용하실때는 UIImage(contendof: 을 이용하십쇼)
    func loadMemoImage(memoId: String) -> String?{
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(memoId)
        do {
            let items = try fileManager.contentsOfDirectory(at: memoPath, includingPropertiesForKeys: nil, options: [])
            if let imagePath = items.first(where: { $0.pathExtension == "jpeg" }) {
                return imagePath.path
            }
        } catch {
            return nil
        }
        return nil
    }
    
    func loadMemoImageUrl(memoId: String) -> URL?{
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(memoId)
        do {
            let items = try fileManager.contentsOfDirectory(at: memoPath, includingPropertiesForKeys: nil, options: [])
            if let imagePath = items.first(where: { $0.pathExtension == "jpeg" }) {
                return imagePath
            }
        } catch {
            return nil
        }
        return nil
    }
    
    /// 폴더 이미지를 찾아 드립니다 만약 없다면 nil을 보내니 거기서 판단해주세여
    func findFolderImage(folderId: String) -> String? {
        // 1. 폴더 URL 까지 이동
        let folderPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(folderId)
        do {
            let items = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil, options: [])
            let image = items.filter { $0.pathExtension == "jpeg"}.first
            guard let image else {return nil }
            
            return image.path
        } catch {
            return nil
        }
    }
    func makeDataToImage(data: Data){
        
    }
    
    
    // MARK: 메모의 관련된 마커이미지 저장 방식 // 덮어씌움
    func saveMarkerImageForMemo(memoId: String, imageData: Data) -> Bool {
        
        guard let image = UIImage(data: imageData) else { return false}
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return false }
        
        let memoImagesDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = memoImagesDirectory.appendingPathComponent("\(memoId).jpeg")
        
        do {
            try imageData.write(to: imagePath)
            return true
        } catch {
            return false
        }
        
    }
    // MARK: 원본 파이일이 있다면 덮어 씌웁니다.
    func saveMarkerZipImageForMemo(memoId: String, imageData: Data?) -> Bool{
        guard let imageData,
              let image = UIImage(data: imageData) else {
            return false
        }
        // TEST 영역 // 30 30 이였고 다른 메서드 였다. 
        let resizing = image.resizeImageTo(CGSize(width: 40, height: 40))
        let imageDa = resizing?.jpegData(compressionQuality: 1)
        
        guard let imageDa else { return false }
        
        let memoImagesDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoImagesDirectory.appendingPathComponent("\(memoId)-40.jpeg")
        
        do {
            try imageDa.write(to: imagePath)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: 마커이미지를 가져옵니다.
    func loadImageMarkerImage(memoId: String) -> String?{
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoPath.appendingPathComponent("\(memoId)-40.jpeg")
        if FileManager.default.fileExists(atPath: imagePath.path()){
            return imagePath.path()
        } else {
            return nil
        }
    }
    func loadImageMarkerImageUrl(memoId: String) -> URL?{
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoPath.appendingPathComponent("\(memoId)-40.jpeg")
        if FileManager.default.fileExists(atPath: imagePath.path()){
            return imagePath
        } else {
            return nil
        }
    }
    func findMarkerImage(memoId: String, completion: ((Result<Data?,RealmManagerError>) -> Void)) {
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = memoPath.appendingPathComponent("\(memoId)-40.jpeg")
        
        if fileManager.fileExists(atPath: imagePath.path()) {
            do {
                let imageData = try Data(contentsOf: imagePath)
                completion(.success(imageData))
            } catch {
                completion(.failure(.canModifiMemo))
            }
        } else {
            completion(.success(nil))
        }
    }
    
    // MARK: 마커 오리지널 이미지를 가져옵니다.
    /// 마커 오리지널 이미지를 가져옵니다.
    func loadImageOrignerMarker(memoId: String) -> String? {
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoPath.appendingPathComponent("\(memoId).jpeg")
        if FileManager.default.fileExists(atPath: imagePath.path()){
            return imagePath.path()
        } else {
            return nil
        }
    }
    func loadImageOrignerMarker(_ memoId: String) -> URL? {
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoPath.appendingPathComponent("\(memoId).jpeg")
        if FileManager.default.fileExists(atPath: imagePath.path()){
            return imagePath
        } else {
            return nil
        }
    }
    
    // MARK: 마커 이미지를 제거합니다. 완전 성공 확인
    func removeMarkerImageAtMemo(memoIdString: String) -> Bool {
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoPath.appendingPathComponent("\(memoIdString).jpeg").path()
        let markerPath = memoPath.appendingPathComponent("\(memoIdString)-40.jpeg").path()
        if fileManager.fileExists(atPath: imagePath) {
            do {
                try fileManager.removeItem(atPath: imagePath)
            } catch {
                return false
            }
        }
        if fileManager.fileExists(atPath: markerPath) {
            do {
                try fileManager.removeItem(atPath: markerPath)
            } catch {
                return false
            }
        }
        return true
    }
    
    // MARK : 이미지 리스트 파일을 제거합니다 반복문 부탁드립니다.
    func removeImageListAtMemo(memoidString: String ,ImageIdString: String) -> Bool{
        let memoPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = memoPath.appendingPathComponent("\(memoidString)/\(ImageIdString).jpeg")
        
        if fileManager.fileExists(atPath: imagePath.path) {
            do {
                try fileManager.removeItem(at: imagePath)
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    // MARK: detailMemoId 를 폴더로 (중복체크) ImageOJID 를 이미지 이름으로
    /// detailMemoId 를 폴더로 (중복체크) ImageOJID 를 이미지 이름으로
    func createMemoImage(detailMemoId: String,imgOJId: String, data: Data) -> Bool {
        // 1. 디렉토리 가져오기
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        // 2. 폴더 경로를 생성
        let fileUrl = directory.appendingPathComponent(detailMemoId)
        
        // 3. 폴더가 없으면 새로 생성
        if !fileManager.fileExists(atPath: fileUrl.path()) {
            do {
                try fileManager.createDirectory(at: fileUrl, withIntermediateDirectories: true)
            } catch {
                return false
            }
        }
        
        // 4. 이미지 경로 설정
        let imageUrl = fileUrl.appendingPathComponent("\(imgOJId).jpeg")
        
        // 5. 이미지 경로 중복 체크후 -> 중복일시 수행 안함.
        if fileManager.fileExists(atPath: imageUrl.path()) {
            return false
        }
        
        // 6. 이미지 데이터 압축 -> 저장
        guard let imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.8) else {
            return false
        }
        
        do {
            try imageData.write(to: imageUrl)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: DetailId 를 통해 이미지 데이터들을 반환해드립니다.
    func findDetailImageData(detailID: String, imageIds: [String]) -> Result<[Data],fileManagerError>{
        guard let diretory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cantFindDocuments)
        }
        
        let folderUrl = diretory.appendingPathComponent("\(detailID)")
        
        var imageDatas: [Data] = []
        
        for imageId in imageIds {
            let imageUrl = folderUrl.appendingPathComponent("\(imageId).jpeg")
            do { 
                let imageData = try Data(contentsOf: imageUrl)
                imageDatas.append(imageData)
            } catch {
                return .failure(.cantFindImages)
            }
        }
        return .success(imageDatas)
    }
    
    func findDetailImageDataUrl(detailID: String, imageIds: [String]) -> Result<[URL],fileManagerError>{
        
        guard let diretory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cantFindDocuments)
        }
        
        let folderUrl = diretory.appendingPathComponent("\(detailID)")
        
        var imageDatas: [URL] = []
        
        for imageId in imageIds {
            let imageUrl = folderUrl.appendingPathComponent("\(imageId).jpeg")
//            do {
//                let imageData = try Data(contentsOf: imageUrl)
//                imageDatas.append(imageData)
//            } catch {
//                return .failure(.cantFindImages)
//            }
            imageDatas.append(imageUrl)
        }
        return .success(imageDatas)
    }
    
    /// 디테일 이미지 리스트를 제거합니다.
    func removeDetailImageList(detailId: String, imageIds: [String] ) -> Result<Void,fileManagerError> {
        // 1. 도큐먼트
        guard let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cantFindDocuments)
        }
        
        let folderUrl = document.appendingPathComponent("\(detailId)")
      
        for imageId in imageIds {
           
            let imageUrl = folderUrl.appendingPathComponent("\(imageId).jpeg")
            
            if fileManager.fileExists(atPath: imageUrl.path()){
                do {
                    try fileManager.removeItem(atPath: imageUrl.path())
                } catch {
                    return .failure(.cantRemoveImages)
                }
            }
        }
        // 이미지를 모두 지운 후 폴더가 비어있는지 확인
        if let files = try? fileManager.contentsOfDirectory(atPath: folderUrl.path), files.isEmpty {
            do {
                try fileManager.removeItem(at: folderUrl)
            } catch {
                return .success(())
            }
        }
        return .success(())
    }
    
    // MARK: 이미지 하나만 지웁니다.
    /// 디테일 이미지 단일만 지웁니다.
    func removeDetailImage(detailId: String, imageId: String) -> Result<Void, fileManagerError> {
        guard let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cantFindDocuments)
        }
        let folderUrl = document.appendingPathComponent("\(detailId)")
      
        let imageUrl = folderUrl.appendingPathComponent("\(imageId).jpeg")
        
        if fileManager.fileExists(atPath: imageUrl.path()){
            do {
                try fileManager.removeItem(atPath: imageUrl.path())
            } catch {
                return .failure(.cantRemoveImages)
            }
        }
        if let files = try? fileManager.contentsOfDirectory(atPath: folderUrl.path), files.isEmpty {
            do {
                try fileManager.removeItem(at: folderUrl)
            } catch {
                return .success(())
            }
        }
        return .success(())
    }
    
    // MARK: 코드 리펙토링 해야함
    func detailImageListUpdate(dtMemoId: String, originId: [String] ,imageObjectId: [String], imageData: [Data]){
        // 1. 일단 폴더로 접근
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return // 치명적 이슈
        }
        // 지우면 안되는 파일 담아놓기
        let originerFile = originId.map { $0 + ".jpeg" }
        var imageDatas = imageData
        
        let folderUrl = documents.appendingPathComponent(dtMemoId)
        // 폴더에 속한 모든 파일 가져오기
        do {
            let allFileList = try fileManager.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            dump(allFileList)
            for imageUrl in allFileList {
                // 마지막 경로 컴포턴츠 로 걸러보기
                print(imageUrl.lastPathComponent)
                let ifDeleteImage = imageUrl.lastPathComponent
                
                // 만약 원하지 않는 이미지에 속하지 않는다면
                if !originerFile.contains(ifDeleteImage){
                    print("??????? ")
                    do {
                        try fileManager.removeItem(at:  folderUrl.appendingPathComponent(ifDeleteImage))
                    } catch {
                        print("이때는 삭제를 실패 했을경우 \n ")
                    }
                }
            }
        } catch {
            print("폴더 접근에 실패한 케이스")
        }
       
        let originalCount = originerFile.count
        print("오리진 ", originalCount)
        print("들어온 ", imageDatas.count)
        if originalCount != 0 {
            for _ in 0...originalCount - 1 {
                imageDatas.removeFirst()
            }
        }
        if imageObjectId.count == imageDatas.count {
            for (idString, imageData) in zip(imageObjectId, imageDatas){
                do {
                    let imageUrl = folderUrl.appendingPathComponent(idString + ".jpeg")
                    try imageData.write(to: imageUrl)
                } catch {
                    print("이미지 저장 실패")
                }
            }
        }
    }
    
    
   
    
}
