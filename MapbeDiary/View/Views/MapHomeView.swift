//
//  MapHomeVie.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import SnapKit
import MapKit


final class MapHomeView: BaseView {
    
    let mapView = MKMapView(frame: .zero)
    
    let searchBar = UISearchBar(frame: .zero)
    
    let buttonStack = MapViewStackButtonView(frame: .zero)
    
    var mapviewModel = MapViewModel()
    
    // MARK: 로케이션 메니저
    var locationManager = CLLocationManager()
    
    var locationClosure: ((CLLocationCoordinate2D) -> Void)?
    
    
    override func configureHierarchy() {
        addSubview(mapView)
        addSubview(searchBar)
        addSubview(buttonStack)
    }
    
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            make.horizontalEdges.equalTo(mapView).inset(34)
            make.height.equalTo(60)
        }
        buttonStack.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerY.equalTo(safeAreaLayoutGuide).offset(30)
        }
    }
    override func register() {
        mapView.register(ArtWorkMarkerView.self, forAnnotationViewWithReuseIdentifier: ArtWorkMarkerView.reusebleIdentifier)
    
        
        settingMapView() // MapView Setting
        settingLongTabForMapView()
    }
    override func designView() {
        searchBarSetting()
    }
    
    private func settingMapView(){
        //
        let location = CLLocationCoordinate2D(latitude:37.5664056, longitude: 126.9778222)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: false)
        
        mapView.mapType = .standard
        mapView.backgroundColor = .brown
    }
    
    private func settingLongTabForMapView(){
        // MARK: 롱탭
        let longtap = UILongPressGestureRecognizer(target: self , action: #selector(longTap))
        mapView.addGestureRecognizer(longtap)
    }
    
    
    // MARK: 회고 해야해
    private func searchBarSetting(){
        
        searchBar.setTextFieldBackground(color: .wheetSideBrown, transparentBackground: true)
        searchBar.placeholder = MapTextSection.emptySearcBarText
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [
                    NSAttributedString
                        .Key
                        .foregroundColor : UIColor.wheetDarkBrown
                ]
            )
            
            textField.textColor = .wheetDarkBrown
            if let leftView = textField.leftView as? UIImageView {
                leftView.tintColor = .wheetDarkBrown
            }
        }
        settingSearchBarShadow()
    }
    
    // MARK: 회고 -> 서치바 그림자를 왜 주지 못하는가
    private func settingSearchBarShadow(){
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowRadius = 4.0
        searchBar.layer.shadowOpacity = 0.5
        searchBar.clipsToBounds = false
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


/*
 userLocationButton.snp.makeConstraints { make in
     make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
     make.centerY.equalTo(safeAreaLayoutGuide).offset( 50 )
     make.size.equalTo(50)
 }
 locationMemosButton.snp.makeConstraints { make in
     make.centerX.equalTo(userLocationButton)
     make.bottom.equalTo(userLocationButton.snp.top).inset( -30 )
     make.size.equalTo(40)
 }
 settingButton.snp.makeConstraints { make in
     make.centerX.equalTo(locationMemosButton)
     make.bottom.equalTo(locationMemosButton.snp.top).inset(-30)
     make.size.equalTo(40)
 }
 */

//        searchBar.searchTextField.layer.borderWidth = 1
//        searchBar.searchTextField.layer.shadowColor = UIColor.wheetDark.cgColor
//        searchBar.searchTextField.layer.shadowOpacity = 0.5
//        searchBar.searchTextField.layer.shadowOffset = CGSize(width: 5, height: 5)
//        searchBar.searchTextField.layer.shadowRadius = 5
        // searchBar.layer.masksToBounds = true
