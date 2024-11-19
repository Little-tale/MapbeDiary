//
//  Observable.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation

final class Observable<T>{
    
    var value: T {
        didSet{
           listener?(value)
        }
    }
    
    fileprivate var listener: ((T) -> Void)?
    
    init(_ type: T) {
        self.value = type
    }
    
    func bind(_ listener: @escaping(T) -> Void){
        listener(value)
        self.listener = listener
    }
    
    func guardBind<ob: AnyObject>(object: ob, _ listener: @escaping (ob, T) -> Void ) {
        self.listener = { [weak object] value in
            guard let object else { print("nil obj") ; return }
            listener(object, value)
        }
    }
    
     // 좀더 연구해봐야 하는 부분
    
//    func filter(_ condition: @escaping (T) -> Bool) -> Observable<T> {
//        let filteredObservable = Observable(value)
//        
//        if condition(value) {
//            filteredObservable.value = value
//        }
//
//        self.bind { [weak filteredObservable] newValue in
//            if condition(newValue) {
//                filteredObservable?.value = newValue
//            }
//        }
//        
//        return filteredObservable
//    }

     
}
