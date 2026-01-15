//
//  LocationManager+Rx.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import CoreLocation
import RxSwift
import RxCocoa

final class LocationManagerDelegateProxy:
    DelegateProxy<LocationManager, LocationManagerDelegate>,
    DelegateProxyType,
    LocationManagerDelegate {
    
    fileprivate let currentAuthStateSubject = PublishSubject<CLAuthorizationStatus>()
    fileprivate let didChangeAuthorizationSubject = PublishSubject<CLAuthorizationStatus>()
    fileprivate let didUpdateLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    static func registerKnownImplementations() {
        self.register { LocationManagerDelegateProxy(parentObject: $0, delegateProxy: self) }
    }
    
    static func currentDelegate(for object: LocationManager) -> LocationManagerDelegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: LocationManagerDelegate?, to object: LocationManager) {
        object.delegate = delegate
    }
    
    func currentAuthState(state: CLAuthorizationStatus) {
        currentAuthStateSubject.onNext(state)
        forwardToDelegate()?.currentAuthState(state: state)
    }
    
    func didChangeAuthorizationAuthorized(state: CLAuthorizationStatus) {
        didChangeAuthorizationSubject.onNext(state)
        forwardToDelegate()?.didChangeAuthorizationAuthorized(state: state)
    }
    
    func didUpdateLocation(_ location: CLLocationCoordinate2D) {
        didUpdateLocationSubject.onNext(location)
        forwardToDelegate()?.didUpdateLocation(location)
    }
    
    deinit {
        currentAuthStateSubject.onCompleted()
        didChangeAuthorizationSubject.onCompleted()
        didUpdateLocationSubject.onCompleted()
    }
}

extension Reactive where Base: LocationManager {
    
    var delegate: DelegateProxy<LocationManager, LocationManagerDelegate> {
        LocationManagerDelegateProxy.proxy(for: base)
    }
    
    var currentAuthState: Observable<CLAuthorizationStatus> {
        let proxy = LocationManagerDelegateProxy.proxy(for: base)
        return proxy.currentAuthStateSubject.asObservable()
    }
    
    var didChangeAuthorization: Observable<CLAuthorizationStatus> {
        let proxy = LocationManagerDelegateProxy.proxy(for: base)
        return proxy.didChangeAuthorizationSubject.asObservable()
    }
    
    var didUpdateLocation: Observable<CLLocationCoordinate2D> {
        let proxy = LocationManagerDelegateProxy.proxy(for: base)
        return proxy.didUpdateLocationSubject.asObservable()
    }
}
