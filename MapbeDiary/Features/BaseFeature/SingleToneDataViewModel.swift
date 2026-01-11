//
//  SingleToneDataViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation

class SingleToneDataViewModel {
  
    
    static let shared = SingleToneDataViewModel()
    
    var shardFolderOb: _Observable<Folder?> = _Observable(nil)
    
    var allListFolderOut: _Observable<Folder?> = _Observable(nil)
    var mapViewFloderOut: _Observable<Folder?> = _Observable(nil)
    
    private init(){
        
        shardFolderOb.bind { [weak self] folder in
            guard let self else { return }
            guard folder != nil else { return }
            allListFolderOut.value = shardFolderOb.value
            mapViewFloderOut.value = shardFolderOb.value
        }
    }
}
