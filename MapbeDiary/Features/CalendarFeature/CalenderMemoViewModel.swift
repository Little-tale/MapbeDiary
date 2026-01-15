//
//  CalenderMemoViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import Foundation


class CalenderMemoViewModel {
    
    let repository = MemoRealmRepository.shared
    // In
    let folder: _Observable<FolderEntity?> = _Observable(nil)
    let date: _Observable<Date?> = _Observable(nil)
    let selectIndexPath: _Observable<IndexPath?> = _Observable(nil)
    let eventDate: _Observable<Date?> = _Observable(nil)
    
    // Out
    let locationMemos: _Observable<[LocationMemoEntity]?> = _Observable(nil)
    let selectedLocationMemo: _Observable<LocationMemoEntity?> = _Observable(nil)
    let minDateLocationMemo: _Observable<LocationMemoEntity?> = _Observable(nil)
    let reloadTrigger: _Observable<Void?> = _Observable(nil)
    let dismissTrigger: _Observable<Void?> = _Observable(nil)
    let countDate: _Observable<Int?> = _Observable(nil)
    
    
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
    
    private func findLocation(_ date: Date, folder: FolderEntity) {
        Task { @MainActor in
            do {
                let results = try await repository.findLocationMemos(
                    folderId: folder.id,
                    date: date
                )
                locationMemos.value = results
            } catch {
                locationMemos.value = []
            }
        }
    }
    private func countOfDateLocation(_ date: Date, folder: FolderEntity) {
        Task { @MainActor in
            do {
                countDate.value = try await repository.findLocationMemosCount(
                    folderId: folder.id,
                    date: date
                )
            } catch {
                countDate.value = 0
            }
        }
    }
    
    private func minimemDate(_ folder: FolderEntity){
        Task { @MainActor in
            do {
                let result = try await repository.findMinDateLocationMemo(
                    folderId: folder.id
                )
                minDateLocationMemo.value = result
                reloadTrigger.value = ()
            } catch {
                minDateLocationMemo.value = nil
                reloadTrigger.value = ()
            }
        }
    }
    
    private func returnLocationMemo(_ indexPath: IndexPath) {
        guard let memos = locationMemos.value else { return }
        let memo = memos[indexPath.item]
        selectedLocationMemo.value = memo
        dismissTrigger.value = ()
    }
    
}
