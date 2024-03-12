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
    
    var outPutCountBool: Observable<Bool?> = Observable(nil)
    
    var realmError: Observable<RealmManagerError?> = Observable(nil)
    
    var repo = RealmRepository()
    
    init(){
     
        inputTrigger.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
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
        if memos.isEmpty {
            outPutCountBool.value = false
        } else {
            outPutCountBool.value = true
        }
    }
    
    // MARK: 메모를 지웁니다!!
    private func deleteMemo(memo: Memo){
        do {
            try repo.deleteAllImageFromMemo(memoId: memo.id)
        } catch {
            realmError.value = error as? RealmManagerError
        }
        SingleToneDataViewModel.shared.shardFolderOb.value = SingleToneDataViewModel.shared.shardFolderOb.value
    }
    deinit{
        print("AllMemoListViewModel", self  )
    }
}
