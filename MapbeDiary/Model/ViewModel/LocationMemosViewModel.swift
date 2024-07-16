//
//  LocationMemosViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/16/24.
//

import Foundation


struct LocationInfo{
    let locationName: String
    let locationMemo: String?
    let phoneNumber: String?
    let regDate: String
}

final class LocationMemosViewModel {
    
    let infoInput: Observable<LocationMemo?> = Observable(nil)
    
    let infoOuput: Observable<LocationInfo?> = Observable(nil)
    
    init(){
        infoInput.bind { [weak self] location in
            guard let self else { return }
            guard let location else { return }
            processing(location)
        }
    }
    private func processing(_ model: LocationMemo){
        let date = DateFormetters.shared.localDate(model.regdate)
        
        let completion = LocationInfo(locationName: model.title, locationMemo: model.contents, phoneNumber: model.phoneNumber, regDate: date)
        
        infoOuput.value = completion
    }
    
}
