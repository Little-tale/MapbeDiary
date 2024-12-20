//
//  MapiViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit
import CoreLocation
import Toast
import FloatingPanel

enum PanelViewControllerType {
    case addLocation
    case modiFiLocation
    
    func createViewController() -> UIViewController {
        switch self {
        case .addLocation:
            return AddLocationMemoViewController()
        case .modiFiLocation:
            return AboutLocationViewController()
        }
    }
}
enum PanelLayoutType {
    case detail
    case custom
    
    var layout : FloatingPanelLayout {
        switch self {
        case .detail:
            return FloatingCustomMemoLayout()
        case .custom:
            return FloatingLocationLayout()
        }
    }
}


struct PanelConfiguration {
    var coordinate: CLLocationCoordinate2D?
    var viewType: PanelViewControllerType
    var configureAddMemoViewController: ((UIViewController) -> Void)?
    var layoutType: PanelLayoutType
    
    func setUpViewController() -> UIViewController {
        let vc = viewType.createViewController()
        configureAddMemoViewController?(vc)
        return vc
    }
}

final class MapViewController: BaseHomeViewController<MapHomeView> {
    
    var floatPanel: FloatingPanelController?
    
    var ifURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        settingMapView() /// 맵뷰 세팅
        checkDeviewlocationAuthorization() // 디바이스 권한
        settinglongPressClosure() // 롱프레스
        settingMapButtonAction() // 버튼 액션들
        homeView.searchBar.delegate = self
        foreGroudWidget()
        addTestAnnotations() // 시작할때 폴더 기준으로
        
        NotificationCenter.default.addObserver(self, selector: #selector(widgetNV), name: .getWidget, object: nil)
    }
    
    func foreGroudWidget(){
        if let ifURL {
            if ifURL == "widget://Search"{
                homeView.searchBar.becomeFirstResponder()
            }
            else {
                homeView.searchBar.text = ifURL
            }
            self.ifURL = nil
        }
    }
    
    @objc
    func widgetNV(_ noti: Notification) {
        if let value = noti.object as? String {
            if value == "widget://Search" {
                homeView.searchBar.becomeFirstResponder()
            }
        }
    }
    
    // MARK: 맵뷰 세팅
    func settingMapView(){
        homeView.locationManager.delegate = self
        homeView.mapView.delegate = self //
        homeView.locationManager.requestWhenInUseAuthorization() // 위치정보를 가져옵니다.
        view.backgroundColor = .wheetLightBrown
    }
    
    // MARK: 판넬 세팅 수정해 -> 네비 없애고 리팩토링 진행
    func settingPanel(view: UIViewController, layout: PanelLayoutType) -> FloatingPanelController{
        let fvc = FloatingPanelController(delegate: self)
        let vc = view
        fvc.set(contentViewController: vc) // 다음뷰
        fvc.layout = layout.layout
        // FloatingLocationLayout() // 커스텀
        fvc.invalidateLayout() // 레이아웃 if need
        fvc.isRemovalInteractionEnabled = false // 내려가기 방지
        fvc.addPanel(toParent: self,animated: true) // 관리뷰
        fvc.surfaceView.layer.cornerRadius = 20
        fvc.surfaceView.clipsToBounds = true
        return fvc
    }

}
// MARK: 어노테이션
extension MapViewController {
    // 어노테이션 박아 -> 꺼내서 너가 수정해
    func addTestAnnotations() {
        removeAll()
        if let locations = homeView.mapviewModel.locationsOutput.value {
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
        let location = CustomAnnotation(memoRegDate: nil, memoId: nil, title: MapTextSection.noneName , coordinate: cl2, bool: true)
        homeView.mapView.addAnnotation(location)
        setRegion(location: location.coordinate,latM: 500,longM: 500)
        homeView.mapView.selectAnnotation(location, animated: true)
    }
    
    // MARK: 어노테이션 전부 지우기
    func removeAll(){
        let anotaions = homeView.mapView.annotations
        homeView.mapView.removeAnnotations(anotaions)
    }
}

// MARK: 버튼 액션
extension MapViewController {
    
    private func settingMapButtonAction(){
        userLocationAction()
        locationMemosButtonAction()
        // movetoLocationListView()
        moveToSettingBttonAction()
        moveToCalendarButtonAction()
    }
    
    private func userLocationAction(){
        homeView.buttonStack.userLocationButton.addAction(UIAction.guardSelf(self, handler: { owner, _ in
            owner.checkDeviewlocationAuthorization() // 권한 확인
            if let locationInfo = owner.homeView.locationManager.location {
                
                if !owner.finduserAnnotationOrNew(CL2D: locationInfo.coordinate) {
                    
                    owner.addLongAnnotation(cl2: locationInfo.coordinate)
                    owner.updatePanel(coordi: locationInfo.coordinate, viewType: .addLocation, layout: .custom, completion: nil)
                }
            }
        }), for: .touchUpInside)
    }
    
    private func locationMemosButtonAction(){
        homeView.buttonStack.locationMemosButton.addAction(
            UIAction.guardSelf(self, handler: { owner, _ in
                owner.removeExistingPanelIfNeeded {
                    owner.movetoLocationListView()
                }
            }),
            for: .touchUpInside
        )
    }
    
    // MARK: 로케이션 메모들 리스트 뷰 이동
    private func movetoLocationListView(){
        let vc = AllMemoLocationListViewController()
        let folder = SingleToneDataViewModel.shared.shardFolderOb.value
        vc.homeView.allMemoViewModel.inputTrigger.value = folder
        vc.locationDelegate = self
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
    
    // MARK: 세팅 뷰컨이동
    private func moveToSettingBttonAction(){
        let action = UIAction.guardSelf(self) { owner, _ in
            let vc = SettingViewController()
            vc.homeView.settingViewModel.inputFolder.value = owner.homeView.mapviewModel.folderInput.value
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .fullScreen
            owner.present(nvc, animated: true )
        }
        homeView.buttonStack.settingButton.addAction(action, for: .touchUpInside)
    }
    
    // MARK: 캘린더 뷰 이동
    func moveToCalendarButtonAction(){
        
        let action = UIAction.guardSelf(self) { owner, _ in
            let vc = CalenderMemoViewController()
            vc.homeView.viewModel.folder.value = owner.homeView.mapviewModel.folderInput.value
            let nvc = UINavigationController(rootViewController: vc)
            
            vc.homeView.viewModel.selectedLocationMemo.bind { memo in
                guard let memo else { return }
                owner.getLocationInfo(memo: memo)
            }
            nvc.modalPresentationStyle = .fullScreen
            owner.present(nvc, animated: true)
        }
        
        homeView.buttonStack.calendarButton.addAction(action, for: .touchUpInside)
    }
    
}


extension MapViewController {
    
    private func subscribe(){
        SingleToneDataViewModel.shared.mapViewFloderOut.guardBind(object: self) { owner, folder in
            guard let folder else { return }
            owner.homeView.mapviewModel.folderInput.value = folder
            owner.removeAll()
            owner.addTestAnnotations()
        }
        
        homeView.mapviewModel.locationsOutput.guardBind(object: self) { owner, locations in
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
            updatePanel(coordi: location, viewType: .addLocation, layout: .custom) { viewCon in
                if let vc = viewCon as? AddLocationMemoViewController {
                    vc.setTitle(text: data.placeName)
                }
            }
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
    // MARK: 기존것을 선택했을때, 회고 해결...!
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("롱: didSelect")
        if let annotaion = view.annotation as? CustomAnnotation,
           !annotaion.long{
            
            homeView.mapView.setCenter(annotaion.coordinate, animated: true)
            //locationModify(annotaion) // 일단 이렇게
            locationDetailModify(annotaion)
        } else {
            let clust = view.annotation
            if let location = clust?.coordinate {
                setRegion(location: location, latM: 300, longM: 300)
            }
        }
    }

    private func locationModify(_ anno: CustomAnnotation){
        if let memoid = anno.locationId {
            updatePanel(coordi: nil, viewType: .addLocation, layout: .custom) { [weak self] viewController in
                guard self != nil else { return }
                if let vc = viewController as? AddLocationMemoViewController {
                    vc.setModifier(text: memoid)
                }
            }
        }
    }
    
    private func locationDetailModify(_ anno: CustomAnnotation){
        print("롱? :locationDetailModify" )
        updatePanel(coordi: nil, viewType: .modiFiLocation, layout: .detail) { [weak self] vc in
            guard let viewController = vc as? AboutLocationViewController else { return }
            guard self != nil else { return }
            viewController.viewModel.inputLocationId.value = anno.locationId
        }
    }
}
// MARK: 판넬 뷰
extension MapViewController: FloatingPanelControllerDelegate {
    
    // MARK: 롱프레스 업데이트 플로팅 패널
    func settinglongPressClosure(){
        homeView.locationClosure = {[weak self] result in
            print("롱프레스 감지")
            guard let self else {return}
            removeAll() // 일단 다 지우기
            addTestAnnotations() // 렘 정보 가져오기
            updatePanel(coordi: result, viewType: .addLocation, layout: .custom, completion: nil ) // 판넬 업데이트
            addLongAnnotation(cl2: result)// 롱프레스
        }
    }
    
    func updatePanel(coordi:  CLLocationCoordinate2D?, viewType:PanelViewControllerType,layout: PanelLayoutType , completion: ((UIViewController) -> Void)?){
        updateFloatingPanel(with:PanelConfiguration(coordinate: coordi, viewType: viewType, configureAddMemoViewController: { [weak self] vc in
            guard self != nil else { return }
            completion?(vc)
        }, layoutType: layout))
        
    }

    private func updateFloatingPanel(with configuration: PanelConfiguration) {
        removeExistingPanelIfNeeded { [weak self] in
            self?.setupPanel(with: configuration)
        }
    }
    
    //MARK: 판넬 가기 설정
    private func setupPanel(with configuration: PanelConfiguration) {

        guard let folder = homeView.mapviewModel.folderInput.value else { return }
        
        var vc = configuration.setUpViewController()
        
        // ADDVIewCon 일때
        if let addMemoVcon = vc as? AddLocationMemoViewController {
            addMemoVcon.backDelegate = self
            if let coordinate = configuration.coordinate {
                let coordinateStruct = addModel(lat: String(coordinate.latitude), lon: String(coordinate.longitude), folder: folder.id.stringValue)
                addMemoVcon.setAddModel(model: coordinateStruct)
            }
            vc = addMemoVcon
        }
        // LocationMemo일때
        if let locationMemo = vc as? AboutLocationViewController {
            locationMemo.backdelegate = self
            locationMemo.locationDelegate = self 
        }
        
        let newPanel = settingPanel(view: vc, layout: configuration.layoutType)
        newPanel.move(to: .half, animated: true)
        floatPanel = newPanel
    }
    
    
    
    // MARK: 판넬을 내리고 싶을때
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
        print("$$$$1")
        floatPanel?.removePanelFromParent(animated: true) {
            [weak self] in
            print("$$$$$2")
            guard let self else {return}
            floatPanel = nil
            addTestAnnotations()
        }
        removeAll()
    }
}
// MARK: 로케이션 수정
extension MapViewController: AboutmodifyLocation {
    
    func getModifyInfo(with lcation: LocationMemo) {
        updatePanel(coordi: nil, viewType: .addLocation, layout: .custom) { [weak self] vc in
            guard self != nil else { return }
            guard let viewController = vc as? AddLocationMemoViewController else { return }
            print("*****   updatePanel ")
            viewController.setModifier(text: lcation.id.stringValue)
        }
    }
}

extension MapViewController: LocationDelegate {
    
    func getLocationInfo(memo: LocationMemo) {
        guard let locations = memo.location else { return }
        guard let location = makeCLLcocation(lon: locations.lon, lat: locations.lat) else { return }
        if !finduserAnnotationOrNew(CL2D: location){
            return
        }
    }
}

extension MapViewController {
    
    func finduserAnnotationOrNew(CL2D: CLLocationCoordinate2D) -> Bool {
        // where First 순회 조건 참조
        let userAnnotation = homeView.mapView.annotations.first { [weak self ] annotation in
            guard self != nil else { return false }
            
            guard let annotation = annotation as? CustomAnnotation else { return false }
            
            return annotation.coordinate.latitude == CL2D.latitude && annotation.coordinate.longitude == CL2D.longitude
            
        }
        guard let custom  = userAnnotation as? CustomAnnotation else { return false }
        homeView.mapView.selectAnnotation(custom, animated: true)
        return true
    }
}

// ----------------------------------------------------------

// MARK: MAPView Loaction 권한 과 위치세팅
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        if let location = locations.last?.coordinate{
            setRegion(location: location,latM: 800,longM: 800)
            homeView.locationManager.distanceFilter = 150 // m단위 변화 할때만 호출
            // homeView.locationManager.stopUpdatingLocation()
        }else {
            homeView.locationManager.stopUpdatingLocation()
        }
    }
    // MARK: 셋 리전
    func setRegion(location: CLLocationCoordinate2D, latM: Double, longM: Double){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: latM, longitudinalMeters: longM)
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
            guard let weakSelf = self else { return }
            /// 만약 디바이스 자체 권한이 활성화 라면 (열겨헝)
            if CLLocationManager.locationServicesEnabled() {
                let authorization: CLAuthorizationStatus
                
                authorization = weakSelf.homeView.locationManager.authorizationStatus
                
                DispatchQueue.main.async {
                    // 유저 위치 권한 상태 확인
                    weakSelf.checkUserLocationAuthorization(authoriztionState: authorization)
                }
            } else {
                DispatchQueue.main.async {
                    weakSelf.goSetting()
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
            showAlert(title: MapTextSection.checkUserAut.alertTitle, message: MapTextSection.checkUserAut.alertMessage, actionTitle: MapTextSection.checkUserAut.actionTitle) {
                [weak self] action in
                guard let self else {return}
                goSetting()
            }
            // MARK: 이시점에서 현위치 가져올수 있음
        case .authorizedAlways, .authorizedWhenInUse:
            homeView.mapView.showsUserLocation = true
            homeView.locationManager.startUpdatingLocation()
            
        default:
            homeView.makeToast(MapTextSection.noneAct.alertMessage,duration: 1.0, position: .bottom)
        }
    }
    

    // 추적 허락 요청
    private func allowLocation(){
        homeView.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        homeView.locationManager.requestWhenInUseAuthorization()
    }
}
