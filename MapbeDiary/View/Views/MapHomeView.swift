//
//  MapHomeVie.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit
import SnapKit
import MapKit


class MapHomeView: BaseView {
    
    let mapView = MKMapView(frame: .zero)
    
    // MARK: 로케이션 메니저
    var locationManager: CLLocationManager!
    
    
    
    override func configureHierarchy() {
        self.addSubview(mapView)
    }
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func designView() {
        //
        let location = CLLocationCoordinate2D(latitude:37.5664056, longitude: 126.9778222)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: false)

        mapView.mapType = .standard
        mapView.backgroundColor = .brown
    }
}
