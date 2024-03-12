//
//  AllMemoListViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import Foundation


class AllMemoListViewModel {
    var inputTrigger: Observable<Folder?> = Observable(nil)
    
    var removeMemo: Observable<Memo?> = Observable(nil)
    
    var reloadTrigger: Observable<Void?> = Observable(nil)
    
    var outPutTrigger: Observable<AllMemoModel?> = Observable(nil)
    
    var repo = RealmRepository()
    
    init(){
     
        inputTrigger.bind { [weak self] folder in
            guard let self else {return}
            guard let folder else {return}
            proceccing(folder:folder)
        }
        reloadTrigger.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            guard inputTrigger.value != nil else { return }

            inputTrigger.value = inputTrigger.value
        }
        
        removeMemo.bind { [weak self] memo in
            guard let self else { return }
            guard let memo else { return }
            deleteMemo(memo: memo)
        }
        
    }
    private func proceccing(folder: Folder){
        let memos = repo.findAllMemoAtFolder(folder: folder)
        outPutTrigger.value = AllMemoModel(folder: folder, Memo: memos)
        
    }
    // MARK: $$$ 메모 지우는거 해야해
    private func deleteMemo(memo: Memo){
        // repo.deleteImageFromMemo(memoId: memo.id, imageName: <#T##String#>)
    }
    
    deinit{
        print("AllMemoListViewModel", self  )
    }
    
}
