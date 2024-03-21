//
//  CustomAnnotation.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit
class CustomAnnotation: NSObject, MKAnnotation {
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
class ArtWorkMarkerView: MKAnnotationView {
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
                image = .defaultMarker.resizeImage(newWidth: 40)
                return
            }
            
            if let imagePath = FileManagers.shard.loadImageMarkerImage(memoId: memoId) {
                settingView()
                
                let image = UIImage(contentsOfFile: imagePath)
                
                centerOffset = CGPoint(x: 0, y: -25)
                // calloutOffset = CGPoint(x: 10, y: 10)
                
                imageView?.image = image?.resizingImage(targetSize: CGSize(width: 70, height: 50))
                
                imageView?.isUserInteractionEnabled = true
            } else {
                image = ImageSection.defaultMarkerImage.image.resizeImage(newWidth: 40)
                centerOffset = CGPoint(x: 0, y: -20)
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
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







// MARK: 이미지 리사이징 회고 한번더 하기 -> 리사이징 한번에 하려고 하면 너무 깨짐
//// MARK: 지도위의 특정 지점을 나타내는 데이터 모델
//final class CustomAnnotation: NSObject, MKAnnotation {
//    var memoDate: Date // 날짜를 기준으로 역 참조 해볼 생각
//    var memoIdString : String//
//    var coordinate: CLLocationCoordinate2D // 기본적인 로케이션
//    var title: String? // 제목
//    
//    // MARK: 이미지 이름? 아니면 처음부터 이미지?
//    var imageName: String? // image이름
//
//    init(coordinate: CLLocationCoordinate2D, memoDate: Date, title: String? = nil, imageName: String? = nil, memoIdString: String) {
//        self.coordinate = coordinate
//        self.memoDate = memoDate
//        self.title = title
//        self.imageName = imageName
//        self.memoIdString = memoIdString
//        super.init()
//    }
//}
//
//final class CustomAnnotationView: MKAnnotationView {
//    
//    override var annotation: MKAnnotation? {
//        willSet{
//            guard let customAnnoatation = newValue as? CustomAnnotation else { return }
//            if let imageName = customAnnoatation.imageName {
//                setUpImage(imageName, memoId: customAnnoatation.memoIdString)
//            }
//            
//        }
//    }
//    
//    private func setUpImage(_ imgName: String, memoId: String) {
        
//        
//        if let image = UIImage(contentsOfFile: imagePath.path) {
//            let resiz = image.resizeImage(newWidth: 40)
//            self.image = resiz
//        } else {
//            let resiz = UIImage(named: "google-309740_1280")?.resizeImage(newWidth: 40)
//            if let resiz {
//                self.image = resiz
//            }
//        }
//        centerOffset = CGPoint(x: 0, y: -20)
//        backgroundColor = .clear
//    }
//
//}


//// MARK: 커스텀 마커 뷰 생성 MKMarkerAnnotationView 를 이용
///// 이유는 어노테이션에 이미지를 사용하려면 mkMarkerAnnotationViewfmf 이용해야함
//final class CustomMarkerAnnotationView: MKMarkerAnnotationView {
//    
//    // MARK:
//    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        
//        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
//        designView()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    private func designView(){
//        backgroundColor = .clear
//    }
//    
//}
