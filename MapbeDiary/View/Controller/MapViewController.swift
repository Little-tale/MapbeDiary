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


struct PanelConfiguration {
    var coordinate: CLLocationCoordinate2D?
    var configureAddMemoViewController: ((AddLocationMemoViewController) -> Void)?
}

class MapViewController: BaseHomeViewController<MapHomeView> {
    
    var floatPanel: FloatingPanelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        settingMapView() /// 맵뷰 세팅
        
        checkDeviewlocationAuthorization() // 디바이스 권한
    
        addTestAnnotations() // 시작할때 폴더 기준으로
        
        homeView.location = {[weak self] result in
            print("asdsadsad")
            guard let self else {return}
            removeAll() // 일단 다 지우기
            addTestAnnotations() // 렘 정보 가져오기
            updateFloatingPanel(with: PanelConfiguration(coordinate: result)) // 판넬 업데이트
            addLongAnnotation(cl2: result) // 롱프레스
        }
        homeView.searchBar.delegate = self
    }
    // MARK: 맵뷰 세팅
    func settingMapView(){
        homeView.locationManager = CLLocationManager()
        homeView.locationManager.delegate = self
        homeView.mapView.delegate = self //
        homeView.locationManager.requestWhenInUseAuthorization() // 위치정보를 가져옵니다.
    }
    
    // MARK: 판넬 세팅 수정해 -> 네비 없애고 리팩토링 진행
    func settingPanel() -> FloatingPanelController{
        let fvc = FloatingPanelController(delegate: self)
        let vc = AddLocationMemoViewController()
        vc.backDelegate = self
        fvc.set(contentViewController: vc) // 다음뷰
        fvc.layout = FloatingLocationLayout() // 커스텀
        fvc.invalidateLayout() // 레이아웃 if need
        fvc.isRemovalInteractionEnabled = false // 내려가기 방지
        fvc.addPanel(toParent: self,animated: true) // 관리뷰
        fvc.surfaceView.layer.cornerRadius = 20
        fvc.surfaceView.clipsToBounds = true
        return fvc
    }
    
    // 어노테이션 박아 -> 꺼내서 너가 수정해
    func addTestAnnotations() {
        print("in Out")
        if let locations = homeView.mapviewModel.locationsOutput.value {
            print("in Out!!!")
            locations.forEach { [weak self] location in
                guard let self else { return }
                addCustomNoFocusforMemo(memo: location)
            }
        }
    }
    
    // MARK: 메모를 통해 커스텀 어노테이션 설정
    func addCustomNoFocusforMemo(memo: LocationMemo){
        let location = memo.location
        guard let location else { return }
        let cl2 = makeCLLcocation(lon: location.lon, lat: location.lat)
        print("????",memo.id.stringValue)
        if let cl2 {
            let customLocation = CustomAnnotation(memoRegDate: memo.regdate, memoId: memo.id.stringValue, title: memo.title, coordinate: cl2)
            homeView.mapView.addAnnotation(customLocation)
        }
    }
    
    // MARK: 롱프레스 하면 커스텀 어노테이션과 포커스
    func addLongAnnotation(cl2: CLLocationCoordinate2D){
        let anno = MKPointAnnotation()
        anno.coordinate = cl2
        let location = CustomAnnotation(memoRegDate: nil, memoId: nil, title: MapAlertSection.noneName , coordinate: cl2)
        homeView.mapView.addAnnotation(location)
        homeView.mapView.setCenter(location.coordinate, animated: true)
        homeView.mapView.selectAnnotation(location, animated: true)
    }
    
    func removeAll(){
        let anotaions = homeView.mapView.annotations
        homeView.mapView.removeAnnotations(anotaions)
    }

}


extension MapViewController {
    func subscribe(){
        SingleToneDataViewModel.shared.mapViewFloderOut.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
            homeView.mapviewModel.folderInput.value = folder
            removeAll()
            addTestAnnotations()
    
        }
        
        homeView.mapviewModel.locationsOutput.bind { [weak self] locations in
            guard let self else { return }
            guard let locations else { return }
            locations.forEach { location in
                self.addCustomNoFocusforMemo(memo: location)
            }
        }

    }
}

// MARK: 서치바 딜리게이트 -> 실제론 그저 다음뷰에서 처리하게 넘김
extension MapViewController : UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 현재 맵 보는 기준으로 맵 중심 Location을 전달할 준비
        let location = homeView.mapView.region.center
        
        // 다음 뷰 컨트롤러로 이동하는 로직을 구현
        let searchViewController = SearchViewController() // 검색 뷰 컨트롤러 인스턴스 생성
        
        let data = SearchModel(searchText: "", long: location.longitude.magnitude, lat: location.latitude.magnitude)
        
        searchViewController.searchViewModel.searchTextOb.value = data
        
        searchViewController.modalPresentationStyle = .fullScreen
        
        present(searchViewController, animated: false)
        // false를 반환하여 서치바가 포커스를 받지 않도록 함
        
        searchViewController.kakaoDataClosure = {
            [weak self] data in
            guard let self else {return}
            
            guard let location = makeCLLcocation(lon:data.x ,lat:data.y) else {
                return
            }
            removeAll()
            /// 판넬 업데이트
            updateFloatingPanel(with: PanelConfiguration(coordinate: location, configureAddMemoViewController: { viewCon in
                viewCon.addViewModel.searchTitle = data.placeName
            }))
            
            addLongAnnotation(cl2: location)
        }
        
        return false
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
    // MARK: 기존것을 선택했을때,
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
        if let annotaion = view.annotation as? CustomAnnotation {
            homeView.mapView.setCenter(annotaion.coordinate, animated: true)
            if let memoid = annotaion.memoId {
                print("@@@@",annotaion)
                updateFloatingPanel(with: PanelConfiguration(configureAddMemoViewController: { viewController in
                    viewController.addViewModel.modifyTrigger.value = memoid
                }))
            }
            
        }
    }
    
}
// MARK: 판넬 뷰
extension MapViewController: FloatingPanelControllerDelegate {
    // MARK: 롱프레스 업데이트 플로팅 패널

    func updateFloatingPanel(with configuration: PanelConfiguration) {
        removeExistingPanelIfNeeded { [weak self] in
            self?.setupPanel(with: configuration)
        }
    }
    //MARK: 판넬 가기 설정
    private func setupPanel(with configuration: PanelConfiguration) {

        guard let folder = homeView.mapviewModel.folderInput.value else { return }
        let newPanel = settingPanel()
        
        if let addMemoVc = newPanel.contentViewController as? AddLocationMemoViewController {
            
            if let coordinate = configuration.coordinate {
                let coordinateStruct = addModel(lat: String(coordinate.latitude), lon: String(coordinate.longitude), folder: folder)
                
                addMemoVc.addViewModel.coordinateTrigger.value = coordinateStruct
            }
            
            // 클로저를 통한 추가 설정
            configuration.configureAddMemoViewController?(addMemoVc)
            
            newPanel.move(to: .half, animated: true)
        }
        floatPanel = newPanel
    }

    private func removeExistingPanelIfNeeded(completion: @escaping () -> Void) {
        if let existingPanel = floatPanel {
            existingPanel.removePanelFromParent(animated: true) { [weak self] in
                self?.floatPanel = nil
                completion()
            }
        } else {
            completion()
        }
    }
    
}

// MARK: 뒤로가기 버튼 감지
extension MapViewController: BackButtonDelegate {
    func backButtonClicked() {
        floatPanel?.removePanelFromParent(animated: true) {
            [weak self] in
            guard let self else {return}
            floatPanel = nil
        }
        removeAll()
        addTestAnnotations()
    }
}

// ----------------------------------------------------------

// MARK: MAPView Loaction 권한 과 위치세팅
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {  // locations [] 를 통해 위치정보를 볼수있다.
        if let location = locations.last?.coordinate{
            // MARK: TS 이부분에서 트러블 슈팅 발생 그렇다면 위치가 변할때만 호출되게 변경
            setRegion(location: location)
            homeView.locationManager.distanceFilter = 10 //m 10미터 변화 할때만 호출
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
    
    // MARK: @@@@컴팩트 알아보기
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
