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
    
}
