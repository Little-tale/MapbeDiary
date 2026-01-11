//
//  SettingVIewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit

class SettingViewModel {
    // repo
    let repository = RealmRepository()
    
    let inputFolder: _Observable<Folder?> = _Observable(nil)
    let removeTrigger: _Observable<Void?> = _Observable(nil)
    
    // output
    let successOut: _Observable<Void?> = _Observable(nil)
    let alertError: _Observable<RealmManagerError?> = _Observable(nil)
    
    init(){
        removeTrigger.bind { [weak self] void in
            guard void != nil else { return }
            self?.removeAll()
        }
    }
    
    private func removeAll() {
        guard let folder = inputFolder.value else {
            return
        }
        repository.removeFolderInEveryThing(folder: folder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                successOut.value = success
            case .failure(let failure):
                alertError.value = failure
            }
        }
    }
}
