//
//  SingleToneDataViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation

@available(*, deprecated, renamed: "SharedEventService", message: "Will be removed in future.")
class SingleToneDataViewModel {
  
    
    static let shared = SingleToneDataViewModel()
    
//    var shardFolderOb: _Observable<Folder?> = _Observable(nil)
    
//    var mapViewFloderOut: _Observable<Folder?> = _Observable(nil)
    
    private init(){
        
//        shardFolderOb.bind { [weak self] folder in
//            guard let self else { return }
//            guard folder != nil else { return }
//            
//            mapViewFloderOut.value = shardFolderOb.value
//        }
    }
}
