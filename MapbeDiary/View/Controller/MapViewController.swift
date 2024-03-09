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
import FloatingPanel

struct testV {
    var title: String
    var lat : String
    var lon : String
    var image: String?
}

class MapViewController: BaseHomeViewController<MapHomeView> {
    
    var floatPanel: FloatingPanelController?
    
    var folder = RealmRepository().findAllFolderArray()[0]
    
    let test = [
        testV(title: "시작 a3a9154c", lat: "35.88232645159043", lon: "126.70855166498062",image: "google-309740_1280"),
        testV(title: "asdasd", lat: "37.62153143200515", lon: "129.8814751149255"),
        testV(title: "vasw", lat: "34.70741906345003", lon: "129.11500797655407"),
        testV(title: "끝 badadsa", lat: "35.04770126585043", lon: "129.46649274833894",image: "google-309740_1280"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingMapView() /// 맵뷰 세팅
        ///
        checkDeviewlocationAuthorization()
      //   customMarker()
        
        addTestAnnotations()
        
        homeView.location = {[weak self] result in
            print("asdsadsad")
            guard let self else {return}
            removeAll()
            addTestAnnotations()
            // PannelViewSend(result)
            updateFloatingPanelContent(result)
            addLongAnnotation(cl2: result)
        }
        
    }
    // MARK: 맵뷰 세팅
    func settingMapView(){
        homeView.locationManager = CLLocationManager()
        homeView.locationManager.delegate = self
        homeView.mapView.delegate = self //
        homeView.locationManager.requestWhenInUseAuthorization() // 위치정보를 가져옵니다.
    }
    func settingPanel() -> FloatingPanelController{
        let fvc = FloatingPanelController(delegate: self)
        let vc = AddMemoViewController()
        vc.backDelegate = self
        
        let nvc = UINavigationController(rootViewController: vc )
        
        fvc.set(contentViewController: nvc) // 다음뷰
        fvc.layout = FloatingCustomLayout() // 커스텀
        fvc.invalidateLayout() // 레이아웃 if need
        fvc.isRemovalInteractionEnabled = false // 내려가기 방지
        fvc.addPanel(toParent: self) // 관리뷰
        return fvc
    }
    
    
    // MARK: 테스트 어노테이션 추가하기 왜 바로 이미지를 못넣는걸까
    
    // 어노테이션 박아 -> 꺼내서 너가 수정해
    func addTestAnnotations() {
        let repo = RealmRepository()

        let test = test.first!
        let cordi = CLLocationCoordinate2D(latitude: Double(test.lat)!, longitude: Double(test.lon)!)
        //
        // homeView.mapView.addAnnotation(cus)
    }
    
    func addCustomAnnotation(){
        
    }
    
    func addLongAnnotation(cl2: CLLocationCoordinate2D){
        let anno = MKPointAnnotation()
        anno.coordinate = cl2
        let location = CustomAnnotation(memoRegDate: nil, memoId: nil, title: MapAlertSection.noneName , coordinate: cl2)
        homeView.mapView.addAnnotation(location)
        homeView.mapView.selectAnnotation(location, animated: true)
    }
    func removeAll(){
        let anotaions = homeView.mapView.annotations
        homeView.mapView.removeAnnotations(anotaions)
    }

}

extension MapViewController: MKMapViewDelegate { // 수정해
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CustomAnnotation {
            var view: ArtWorkMarkerView? = mapView.dequeueReusableAnnotationView(withIdentifier: ArtWorkMarkerView.reusebleIdentifier, for: annotation) as? ArtWorkMarkerView
    
            view = ArtWorkMarkerView(annotation: annotation, reuseIdentifier: CustomAnnotation.reusableIdentifier)
        
            return view
        }
        
        print("asdsadsa")
        return nil
    }
    
}
// MARK: 판넬 뷰
extension MapViewController: FloatingPanelControllerDelegate {
    
    func updateFloatingPanelContent(_ CL: CLLocationCoordinate2D){
        updateAddMemoViewControllerContent(with: CL)
    }
    
    // MARK: 재사용목적 있으면 다음 없으면 재 생성
    private func updateAddMemoViewControllerContent(with coordinate: CLLocationCoordinate2D) {
        floatPanel = settingPanel()
        
        if let navigationController = floatPanel?.contentViewController as? UINavigationController,
           let addMemoVc = navigationController.viewControllers.first as? AddMemoViewController {
            let coordinateStruct = addViewStruct(lat: String(coordinate.latitude), lon: String(coordinate.longitude), folder: folder)
            
            addMemoVc.addViewModel.coordinateTrigger.value = coordinateStruct
            floatPanel?.move(to: .half, animated: true)
            return
        }else {
            showAlert(title: MapAlertSection.panelError.title, message: MapAlertSection.panelError.message)
        }
    }
    
}
extension MapViewController: BackButtonDelegate {
    func backButtonClicked() {
        floatPanel?.removePanelFromParent(animated: true) {
            [weak self] in
            guard let self else {return}
            floatPanel = nil
        }
    }
}

// ----------------------------------------------------------

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
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
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
            // MARK: 이시점에서 현위치 가져올수 있음
        case .authorizedAlways, .authorizedWhenInUse:
            // Optional(__C.CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417))
            homeView.mapView.showsUserLocation = true
            homeView.locationManager.startUpdatingLocation()
            print("@@",homeView.locationManager.location?.coordinate)
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
