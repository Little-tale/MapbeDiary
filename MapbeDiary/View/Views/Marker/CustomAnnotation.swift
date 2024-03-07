//
//  CustomAnnotation.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var imageName: String
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D, imageName: String) {
        self.coordinate = coordinate
        self.imageName = imageName
    }
}
