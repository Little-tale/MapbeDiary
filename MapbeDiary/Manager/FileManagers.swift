//
//  FileManagers.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import Foundation

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
    
}
