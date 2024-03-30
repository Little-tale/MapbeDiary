//
//  CalenderMemoViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import Foundation


class CalenderMemoViewModel {
    
    let repository = RealmRepository()
    
    let folder: Observable<Folder?> = Observable(nil)
    let date: Observable<Date?> = Observable(nil)
    
    let locationMemos: Observable<[LocationMemo]?> = Observable(nil)
    
    init() {
        date.bind { [weak self] date in
            guard let self else { return }
            guard let date else { return }
            guard let folder = folder.value else { return }
            findLocation(date, folder: folder)
        }
    }
    
    private func findLocation(_ date: Date, folder: Folder) {
        let results = repository.findLocationMemos(folder: folder, date: date)
        print(results.count)
        locationMemos.value = results
    }
    
}
