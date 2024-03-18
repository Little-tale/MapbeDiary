//
//  MapHomeVie.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import SnapKit
import MapKit


class MapHomeView: BaseView {
    
    let mapView = MKMapView(frame: .zero)
    
    let userLocationButton = CustomLocationButton(frame: .zero, imageType: .location)
    let locationMemosButton = CustomLocationButton(frame: .zero, imageType: .AllMemo)
    
    let searchBar = UISearchBar(frame: .zero)
    
    var mapviewModel = MapViewModel()
    
    // MARK: 로케이션 메니저
    var locationManager: CLLocationManager!
    
    var locationClosure: ((CLLocationCoordinate2D) -> Void)?
    
    
    override func configureHierarchy() {
        addSubview(mapView)
        addSubview(searchBar)
        addSubview(userLocationButton)
        addSubview(locationMemosButton)
    }
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            make.horizontalEdges.equalTo(mapView).inset(34)
            make.height.equalTo(40)
        }
        userLocationButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(35)
            make.size.equalTo(50)
        }
        locationMemosButton.snp.makeConstraints { make in
            make.centerX.equalTo(userLocationButton)
            make.bottom.equalTo(userLocationButton.snp.top).inset( -18 )
            make.size.equalTo(40)
        }
    }
    override func register() {
        mapView.register(ArtWorkMarkerView.self, forAnnotationViewWithReuseIdentifier: ArtWorkMarkerView.reusebleIdentifier)
    }
    override func designView() {
        //
        let location = CLLocationCoordinate2D(latitude:37.5664056, longitude: 126.9778222)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: false)
        
        mapView.mapType = .standard
        mapView.backgroundColor = .brown
        searchBar.setTextFieldBackground(color: .white, transparentBackground: true)
        searchBar.placeholder = "장소를 검색해 보세요!"
        
        // MARK: 롱탭
        let longtap = UILongPressGestureRecognizer(target: self , action: #selector(longTap))
        
        mapView.addGestureRecognizer(longtap)
        
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            // 변환하고자 하는 위치 즉 맵뷰 기준의 포인트 CGPoint
            let locationInView = sender.location(in: mapView)
            // 해당 위치가 속한 뷰에 CGPoint 를 넘겨서 위치를 반환
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            locationClosure?(locationOnMap) // 위치를 넘겨준다...
        }
        print(sender.state == .ended)
    }
}
