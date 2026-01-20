//
//  CustomAnnotation.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit
import Kingfisher

final class CustomAnnotation: NSObject, MKAnnotation {
    static let reusableIdentifier = "CustomAnnotation"
    
    var memoRegDate: Date? // 메모 데이트를 통해 역으로도 찾을수 있게
    var locationId: String?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var long: Bool

    
    init(memoRegDate: Date?,memoId: String?,title: String? ,coordinate: CLLocationCoordinate2D, bool: Bool? = nil ) {
        self.memoRegDate = memoRegDate
        self.coordinate = coordinate
        self.title = title
        self.locationId = memoId
        self.long = bool ?? false
        
    }
}
