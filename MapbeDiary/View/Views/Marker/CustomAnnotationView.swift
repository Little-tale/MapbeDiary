//
//  CustomAnnotationMarker.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//


import MapKit

// MARK: 커스텀 마커 생성
class CustomAnnotationMarker: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        designView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func designView(){
        backgroundColor = .clear
    }
    
}
