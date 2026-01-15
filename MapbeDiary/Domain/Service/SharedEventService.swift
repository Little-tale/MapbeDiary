//
//  SharedEventService.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import RxSwift

final class SharedEventService: SharedEventProtocol {
    
    let event = PublishSubject<SharedEvent>()
    
    func send(_ event: SharedEvent) {
        self.event.onNext(event)
    }
}
