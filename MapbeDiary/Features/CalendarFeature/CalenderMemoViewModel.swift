//
//  CalenderMemoViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import Foundation


class CalenderMemoViewModel {
    
    let repository = RealmRepository()
    // In
    let folder: Observable<Folder?> = Observable(nil)
    let date: Observable<Date?> = Observable(nil)
    let selectIndexPath: Observable<IndexPath?> = Observable(nil)
    let eventDate: Observable<Date?> = Observable(nil)
    
    // Out
    let locationMemos: Observable<[LocationMemo]?> = Observable(nil)
    let selectedLocationMemo: Observable<LocationMemo?> = Observable(nil)
    let minDateLocationMemo: Observable<LocationMemo?> = Observable(nil)
    let reloadTrigger: Observable<Void?> = Observable(nil)
    let dismissTrigger: Observable<Void?> = Observable(nil)
    let countDate: Observable<Int?> = Observable(nil)
    
    
    init() {
       
        date.bind { [weak self] date in
            guard let self else { return }
            guard let date else { return }
            guard let folder = folder.value else { return }
            findLocation(date, folder: folder)
        }
        folder.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
            minimemDate(folder)
        }
        
        selectIndexPath.bind { [weak self] indexPath in
            guard let self else { return }
            guard let indexPath else { return }
            returnLocationMemo(indexPath)
        }
        eventDate.bind { [weak self] date in
            guard let self else { return }
            guard let date else { return }
            guard let folder = folder.value else { return }
            countOfDateLocation(date, folder: folder)
        }
    }
    
    private func findLocation(_ date: Date, folder: Folder) {
        let results = repository.findLocationMemos(folder: folder, date: date)
        print("해당날짜 갯수 : ",results.count)
        locationMemos.value = results
    }
    private func countOfDateLocation(_ date: Date, folder: Folder) {
        countDate.value = repository.findLocationMemosCount(folder, date: date)
    }
    
    private func minimemDate(_ folder : Folder){
        let result = repository.findMinDateLocationMemo(folder: folder)
        minDateLocationMemo.value = result
        reloadTrigger.value = ()
    }
    
    private func returnLocationMemo(_ indexPath: IndexPath) {
        guard let memos = locationMemos.value else { return }
        let memo = memos[indexPath.item]
        selectedLocationMemo.value = memo
        dismissTrigger.value = ()
    }
    
}
