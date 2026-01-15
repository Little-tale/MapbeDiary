//
//  LocationManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    
    func currentAuthState(state: CLAuthorizationStatus)
    
    func didChangeAuthorizationAuthorized(state: CLAuthorizationStatus)
    
    func didUpdateLocation(_ location: CLLocationCoordinate2D)
}

final class LocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    static var defaultLocation = CLLocationCoordinate2D(
        latitude:37.5664056,
        longitude: 126.9778222
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if isAuthorized() {
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationManager {
    
    func isAuthorized() -> Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        @unknown default:
            return false
        }
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        delegate?.currentAuthState(
            state: locationManager.authorizationStatus
        )
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let state = manager.authorizationStatus
        delegate?.didChangeAuthorizationAuthorized(state: state)
        
    
        switch manager.authorizationStatus {
        case .notDetermined:
            print("delegate 의 권한 상태가 결정하지 않음으로 변경되었습니다.")
            
        case .restricted, .denied:
            print("delegate 의 권한 상태가 제한 또는 거절로 변경되었습니다.")
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("delegate 의 권한 상태가 사용 중 허용 또는 허용으로 변경되었습니다.")
            manager.startUpdatingLocation()
            
        @unknown default:
            print("delegate 의 권한 상태가 알 수 없음 으로 변경되었습니다.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last?.coordinate else {
            return
        }
        
        delegate?.didUpdateLocation(location)
    }
}
