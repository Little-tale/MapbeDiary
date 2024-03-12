//
//  AllMemoListViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation


class AllMemoListViewModel {
    var inputTrigger: Observable<Folder?> = Observable(nil)
    
    var outPutTrigger: Observable<(folder: Folder, list: [Memo])?> = Observable(nil)
    
    var repo = RealmRepository()
    
    init(){
        inputTrigger.bind { [weak self] folder in
            guard let self else {return}
            guard let folder else {return}
            proceccing(folder:folder)
        }
    }
    private func proceccing(folder: Folder){
        let memos = repo.findAllMemoAtFolder(folder: folder)
        outPutTrigger.value = (folder,memos)
        print(folder, memos)
    }
    
    deinit{
        print("AllMemoListViewModel", self  )
    }
}
