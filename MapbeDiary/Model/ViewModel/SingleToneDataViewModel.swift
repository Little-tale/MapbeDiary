//
//  SingleToneDataViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation

class SingleToneDataViewModel {
    private init(){}
    
    static let shared = SingleToneDataViewModel()
    
    var shardFolderOb: Observable<Folder?> = Observable(nil)
    
}
