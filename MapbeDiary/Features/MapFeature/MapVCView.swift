//
//  MapVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/15/26.
//

import UIKit
import MapKit
import SnapKit

final class MapVCView: VCBaseView {
    
    let mapView = MKMapView(frame: .zero)
    
    let searchBar = UISearchBar(frame: .zero)
    
    let buttonStack = MapViewStackButtonView(frame: .zero)

    
    
    override func setupHierarchy() {
        addSubview(mapView)
        addSubview(searchBar)
        addSubview(buttonStack)
    }
    
    override func setupConstraints() {
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
        mapView.register(
            ImageMarkerView.self,
            forAnnotationViewWithReuseIdentifier: ImageMarkerView.reusableIdentifier
        )
        mapView.register(
            DefaultMarkerView.self,
            forAnnotationViewWithReuseIdentifier: DefaultMarkerView.reusableIdentifier
        )
    }
    
    override func setupUI() {
        settingMapView()
        settingSearchBar()
    }
}


extension MapVCView {
    
    private func settingMapView(){
        mapView.mapType = .standard
        mapView.backgroundColor = .brown
    }
    
    private func settingSearchBar(){
        // Background
        searchBar.setTextFieldBackground(
            color: .white,
            transparentBackground: true
        )
        
        searchBar.placeholder = MapTextSection.emptySearchBarText
        
        // Shadow
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowRadius = 2.0
        searchBar.layer.shadowOpacity = 0.5
        searchBar.clipsToBounds = false
    }
}
