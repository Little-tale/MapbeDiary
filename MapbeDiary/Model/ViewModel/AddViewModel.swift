//
//  AddViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

class AddViewModel {
    let coordinateTrigger: Observable<(lat: String, lon: String)?> = Observable(nil)
    
    let urlErrorOutPut: Observable<URLSessionManagerError?> = Observable(nil)
    
    init(){
        coordinateTrigger.bind {[weak self] coordi in
            guard let self else {return}
            guard let coordi else {return}
            apiRequest(lat: coordi.lat, lon: coordi.lon)
        }
    }
    
    private func apiRequest(lat: String, lon: String){
        print(lat, lon)
        URLSessionManager.shared.fetch(type: KaKakaoCordinateModel.self, api: KakaoApiModel.cordinate(x: lon, y: lat)) {
            [weak self] results in
            guard self != nil else { return }
            switch results {
            case .success(let success):
                print("출력: ",success.documents)
            case .failure(let fail):
                print("통신실패")
                self?.urlErrorOutPut.value = fail
                print(fail.errorMessage)
            }
        }
    }
    
}
