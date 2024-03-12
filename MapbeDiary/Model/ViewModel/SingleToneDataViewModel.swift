//
//  SingleToneDataViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation

class SingleToneDataViewModel {
  
    
    static let shared = SingleToneDataViewModel()
    
    var shardFolderOb: Observable<Folder?> = Observable(nil)
    
    var allListFolderOut: Observable<Folder?> = Observable(nil)
    var mapViewFloderOut: Observable<Folder?> = Observable(nil)
    
    private init(){
        
        shardFolderOb.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
            allListFolderOut.value = shardFolderOb.value
            mapViewFloderOut.value = shardFolderOb.value
        }
    }
}
