//
//  AboutLocationViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/16/24.
//

import Foundation


class AboutLocationViewModel {
    // input
    let inputLocationMemo: Observable<LocationMemo?> = Observable(nil)
    
    // MARK: -> 해야해
    let inputLocationId: Observable<String?> = Observable(nil)
    
    let removeDetailMemo: Observable<IndexPath?> = Observable(nil)
    
    let removeLocationMemo: Observable<Void?> = Observable(nil)
    
    // output
    let locationInfoOutPut: Observable<LocationMemo?> = Observable(nil)
    let emptyHiddenOutPut: Observable<Bool?> = Observable(nil)
    let detailTableViewData: Observable<[DetailMemo]?> = Observable(nil)
    let fileMangerErrorOutPut: Observable<fileManagerError?> = Observable(nil)
    let repositoryErrorOutPut: Observable<RealmManagerError?> = Observable(nil)
    
    let dismissAction: Observable<Void?> = Observable(nil)
    
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
