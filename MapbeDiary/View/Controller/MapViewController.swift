//
//  MapiViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

// import UIKit
import MapKit
import CoreLocation
import Toast

struct testV {
    var title: String
    var lat : String
    var lon : String
}

class MapViewController: BaseHomeViewController<MapHomeView> {
    
    let test = [
        testV(title: "시작 a3a9154c", lat: "35.88232645159043", lon: "126.70855166498062"),
        testV(title: "asdasd", lat: "37.62153143200515", lon: "129.8814751149255"),
        testV(title: "vasw", lat: "34.70741906345003", lon: "129.11500797655407"),
        testV(title: "끝 badadsa", lat: "35.04770126585043", lon: "129.46649274833894"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingMapView() /// 맵뷰 세팅
        ///
        checkDeviewlocationAuthorization()
      //   customMarker()
        
        addTestAnnotations()
    }
    // MARK: 맵뷰 세팅
    func settingMapView(){
        homeView.locationManager = CLLocationManager()
        homeView.locationManager.delegate = self
        homeView.mapView.delegate = self //
        homeView.locationManager.requestWhenInUseAuthorization() // 위치정보를 가져옵니다.
    }
    
    // MARK: 테스트 어노테이션 추가하기 왜 바로 이미지를 못넣는걸까
    func addTestAnnotations() {
        for testData in test {
            let annotation = MKPointAnnotation()
            annotation.title = testData.title
            if let lat = Double(testData.lat),
               let lon = Double(testData.lon) {
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            homeView.mapView.addAnnotation(annotation)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var view = MKAnnotationView()
//        view.ti
//    }
    
}

// MARK: MAPView Loaction 권한 과 위치세팅
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {  // locations [] 를 통해 위치정보를 볼수있다.
        if let location = locations.last?.coordinate{
            // MARK: TS 이부분에서 트러블 슈팅 발생 그렇다면 위치가 변할때만 호출되게 변경
            setRegion(location: location)
            homeView.locationManager.distanceFilter = 10 // 10미터 변화 할때만 호출
            // homeView.locationManager.stopUpdatingLocation()
        }else {
            homeView.locationManager.stopUpdatingLocation()
        }
    }
    // MARK: 셋 리전
    func setRegion(location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1800, longitudinalMeters: 1800)
        homeView.mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviewlocationAuthorization()
    }
}


extension MapViewController {
    
    /// 사용자의 디바이스의 권한을 확인합니다.
    func checkDeviewlocationAuthorization(){
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            /// 만약 디바이스 자체 권한이 활성화 라면 (열겨헝)
            if CLLocationManager.locationServicesEnabled() {
                let authorization: CLAuthorizationStatus
                
                authorization = homeView.locationManager.authorizationStatus
                
                DispatchQueue.main.async { 
                    [weak self] in
                    guard let self else { return }
                    // 유저 위치 권한 상태 확인
                    self.checkUserLocationAuthorization(authoriztionState: authorization)
                }
            } else {
                DispatchQueue.main.async {
                    self.goSetting()
                }
            }
            
        }
    }
    /// 유저가 앱에 대해서 위치 정보를 주었는지 확인합니다.
    func checkUserLocationAuthorization(authoriztionState: CLAuthorizationStatus){
        print(authoriztionState.rawValue)
        
        switch authoriztionState {
        case .notDetermined: // 설정한 적이 없거나 한번만 허용후 다시 올때
            allowLocation()
        case .denied:
            
            showAlert(title: MapAlertSection.checkUserAut.title, message: MapAlertSection.checkUserAut.message, actionTitle: MapAlertSection.checkUserAut.actionTitle) {
                [weak self] action in
                guard let self else {return}
                goSetting()
            }
        case .authorizedAlways:
            
            homeView.mapView.showsUserLocation = true
            homeView.locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            
            homeView.mapView.showsUserLocation = true
            homeView.locationManager.startUpdatingLocation()
        default:
            homeView.makeToast(MapAlertSection.noneAct.message,duration: 1.0, position: .bottom)
        }
    }
    

    // 추적 허락 요청
    func allowLocation(){
        homeView.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        homeView.locationManager.requestWhenInUseAuthorization()
    }
    
    // 세팅으로 유도합니다.
    func goSetting(){
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        } else {
            showAlert(title: MapAlertSection.requestFail.title, message: MapAlertSection.requestFail.message)
        }
    }
    
}



// MARK: 커스텀 마커
//extension MapViewController {
//    func customMarker() {
//        let pin = MKPointAnnotation()
//        pin.title = "테스트"
//        pin.subtitle = "섭 타이틀 테스트"
//        homeView.mapView.addAnnotation(pin)
//    }
//}
