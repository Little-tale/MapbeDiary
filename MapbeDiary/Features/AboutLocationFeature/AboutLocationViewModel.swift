//
//  AboutLocationViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/16/24.
//

import Foundation


class AboutLocationViewModel {
    // input
    let inputLocationMemo: _Observable<LocationMemo?> = _Observable(nil)
    
    // MARK: -> 해야해
    let inputLocationId: _Observable<String?> = _Observable(nil)
    
    let removeDetailMemo: _Observable<IndexPath?> = _Observable(nil)
    
    let removeLocationMemo: _Observable<Void?> = _Observable(nil)
    
    // output
    let locationInfoOutPut: _Observable<LocationMemo?> = _Observable(nil)
    let emptyHiddenOutPut: _Observable<Bool?> = _Observable(nil)
    let detailTableViewData: _Observable<[DetailMemo]?> = _Observable(nil)
    let fileMangerErrorOutPut: _Observable<FileManagerError?> = _Observable(nil)
    let repositoryErrorOutPut: _Observable<RealmManagerError?> = _Observable(nil)
    
    let dismissAction: _Observable<Void?> = _Observable(nil)
    
    // static
    let repository = RealmRepository()
    
    
    init(){
        inputLocationMemo.bind { [weak self] location in
            guard let self else { return }
            guard let location else { return }
            locationInfoOutPut.value = location
            emptyHiddenOutPut.value = !location.detailMemos.isEmpty
            collectionViewData(location)
        }
        removeDetailMemo.bind { [weak self] indexPath in
            guard let self else { return }
            guard let indexPath else { return }
            deleteDetailMemo(indexPath)
        }
        removeLocationMemo.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            guard let location = inputLocationMemo.value else { return }
            deleteLocationMemo(location)
        }
        inputLocationId.bind { [weak self] locationId in
            guard let self else { return }
            guard let locationId else { return }
            locationIdToLocation(locationId)
        }
    }
    
    private func collectionViewData(_ location: LocationMemo){
        let memos = Array(location.detailMemos)
        detailTableViewData.value = memos
    }
    
    private func deleteDetailMemo(_ indexPath: IndexPath){
        
        guard let location = inputLocationMemo.value else { return }
        let detail = location.detailMemos[indexPath.row]
        
        repository.deleteDetailMemo(detail) { [weak self] results in
            guard let self else { return }
            switch results {
            case .success(_):
                inputLocationMemo.value = inputLocationMemo.value
            case .failure(let failure):
                repositoryErrorOutPut.value = failure
            }
        }
    }
    
    private func deleteLocationMemo(_ location: LocationMemo) {
        repository.deleteLocationMemo(location) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                dismissAction.value = ()
            case .failure(let failure):
                repositoryErrorOutPut.value = failure
            }
        }
    }
    
    private func locationIdToLocation(_ locationID: String){
        repository.findLocationMemo(ojidString: locationID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                inputLocationMemo.value = success
            case .failure(let failure):
                repositoryErrorOutPut.value = failure
            }
        }
    }
    
}
