//
//  MapVIewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation


class MapViewModel {
    
    var folderInput: Observable<Folder?> = Observable(nil)

    var locationsOutput: Observable<[LocationMemo]?> = Observable(nil)
    
    var reloadInput: Observable<Void?> = Observable(nil)
    
    var repository = RealmRepository()
    init(){
        // 처음 시작시 첫번째 폴더로
        let folder = repository.findAllFolder().first
        folderInput.value = folder

        folderInput.bind { [weak self] folder in
            guard let folder else { return }
            guard let self else { return }
            findFolderAtLoactionMemo(folder: folder)
        }
        reloadInput.bind { [weak self] void in
            guard let self else { return }
            guard let void else { return }
            guard let folder  = folderInput.value else { return }
            folderInput.value = folderInput.value
        }
    }
    
    private func findFolderAtLoactionMemo(folder: Folder){
        let locations = repository.findLocationMemoForFolder(folder: folder)
        locationsOutput.value = locations
    }
}
