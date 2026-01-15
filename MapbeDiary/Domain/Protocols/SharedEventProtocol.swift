//
//  SharedEventProtocol.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import RxSwift


enum SharedEvent: Equatable {
    case removedMemo(LocationMemoEntity)
    case needReloadMemos
    case widgetAction(WidgetAction)
}

protocol SharedEventProtocol: AnyObject {
    var event: PublishSubject<SharedEvent> { get }
    
    func send(_ event: SharedEvent)
}
