//
//  FileManagers.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit

class FileManagers {
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
    
    
    // MARK: 메모의 관련된 마커이미지 저장 방식 // 덮어씌움
    func saveMarkerImageForMemo(memoId: String, image: UIImage) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return false }
        let memoImagesDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoImagesDirectory.appendingPathComponent("\(memoId).jpeg")
        do {
            try imageData.write(to: imagePath)
            return true
        } catch {
            return false
        }
    }
    func saveMarkerZipImageForMemo(memoId: String, image: UIImage?) -> Bool{
        guard let image else { return false }
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return false}
        let memoImagesDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = memoImagesDirectory.appendingPathComponent("\(memoId)-40.jpeg")
        do {
            try imageData.write(to: imagePath)
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
    
    
}
