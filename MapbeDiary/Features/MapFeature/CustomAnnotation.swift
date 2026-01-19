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

// 이미지 뷰 넣어서 하는거 고려
// 이미지 뷰를 넣어서 했을떄 랑 아니였을때의 메모리 사용량 비교
// imageView.image = nil 을 안했을때 문제점
final class ArtWorkMarkerView: MKAnnotationView {
    var imageView: UIImageView?
    
    override var annotation: MKAnnotation? {
        willSet {
            image = nil
            imageView?.image = nil
            imageView = nil
            
            guard let artWork = newValue as? CustomAnnotation else { return }
            
            guard let memoId = artWork.locationId else {
                canShowCallout = true
                imageView = nil
                // calloutOffset = CGPoint(x: 0, y: 10)
                centerOffset = CGPoint(x: 0, y: -20)
                image = .defaultMarker.resizeImage(maxDimension: 40)
                return
            }
            
            if let imagePath = FileManagers.shard.loadImageMarkerImageUrl(memoId: memoId) {
                settingView()
                
                centerOffset = CGPoint(x: 0, y: -25)
               
                imageView?.kf.setImage(with: imagePath)
                
                imageView?.isUserInteractionEnabled = true
            } else {
                image = ImageSection.defaultMarkerImage.image.resizeImage(maxDimension: 40)
                centerOffset = CGPoint(x: 0, y: -20)
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
            
            clusteringIdentifier = "clllasdllasdl"
        }

    }
    
    
    private func settingView(){
        imageView = UIImageView()
        imageView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        if let imageView {
            addSubview(imageView)
        }
        
    }
    
    
    deinit {
        print("dinit: ", self)
    }
    
}
