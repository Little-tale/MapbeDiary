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
import RxSwift
import RxCocoa

enum PanelViewControllerType: Equatable {
    case addLocation
    case about(memoId: String)
    case modify(memoId: String)
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
    var layoutType: PanelLayoutType
    var folderID: String
}

// FIXME: 서치바 계속 나오는 문제
final class MapViewController: ReactorBaseViewController<MapViewReactor, MapVCView> {
    
    private var floatPanel: FloatingPanelController?
    private var pendingPanelConfiguration: PanelConfiguration?
    private var currentMemos: [LocationMemoEntity] = []
    private var lastLocation: CLLocationCoordinate2D?
    private let searchBarTapGesture = UITapGestureRecognizer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wheetLightBrown
        setupLongPressGesture()
        setupSearchBarTap()
    }
    
    override func bind(reactor: MapViewReactor) {
        super.bind(reactor: reactor)
        
        reactor.pulse(\.$moveToSearch)
            .filter{ $0 == true }
            .bind(with: self) { owner, bool in
                owner.moveToSearchView()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.location }
            .distinctUntilChanged { lhs, rhs in
                let first = (lhs.latitude == rhs.latitude)
                let second = (lhs.longitude == rhs.longitude)
                return first && second
            }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, location in
                owner.lastLocation = location
                owner.setRegion(
                    location: location,
                    latM: 800,
                    longM: 800
                )
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$moveToSetting)
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.goSetting()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showSettingAlert)
            .filter{ $0 == true }
            .skip(1)
            .bind(with: self) { owner, _ in
                owner.showGoSettingAlert()
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.currentMemos }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, memos in
                owner.currentMemos = memos
                owner.addTestAnnotations()
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$showsUserLocation)
            .filter{ $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, shows in
                owner.mainView.mapView.showsUserLocation = shows
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$realmError)
            .compactMap{ $0 }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$sendCalendarView)
            .compactMap{ $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, model in
                owner.moveToCalendarView(model: model)
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: MapViewReactor) {
        
        rx.viewDidLoad
            .map { _ in MapViewReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBarTapGesture.rx
            .event
            .map { _ in MapViewReactor.Action.setDeepLink(WidgetAction.search.path) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.buttonStack.userLocationButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.reactor?.action.onNext(.checkLocationWhenInUseAuthorization)
                guard let locationInfo = owner.lastLocation else { return }
                
                if !owner.finduserAnnotationOrNew(CL2D: locationInfo) {
                    owner.addLongAnnotation(cl2: locationInfo)
                    owner.showPanel(
                        coordinate: locationInfo,
                        viewType: .addLocation,
                        layout: .custom
                    )
                }
            }
            .disposed(by: disposeBag)
        
        mainView.buttonStack.locationMemosButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.removeExistingPanelIfNeeded {
                    owner.movetoLocationListView()
                }
            }
            .disposed(by: disposeBag)
        
        mainView.buttonStack.settingButton.rx
            .tap
            .bind(with: self) { owner, _ in
                let vc = SettingViewController(
                    reactor: SettingViewReactor()
                )
                
                let nvc = UINavigationController(rootViewController: vc)
                nvc.modalPresentationStyle = .fullScreen
                owner.present(nvc, animated: true )
            }
            .disposed(by: disposeBag)
        
        mainView.buttonStack.calendarButton
            .rx
            .tap
            .map { _ in MapViewReactor.Action.calendarButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    override func register() {
        mainView.mapView.delegate = self
    }
}

// MARK: Helpers
extension MapViewController {
    
    // MARK: 셋 리전
    func setRegion(
        location: CLLocationCoordinate2D,
        latM: Double,
        longM: Double
    ){
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: latM,
            longitudinalMeters: longM
        )
        
        mainView.mapView.setRegion(region, animated: true)
    }
    
    private func showGoSettingAlert() {
        showAlert(title: MapTextSection.checkUserAut.alertTitle, message: MapTextSection.checkUserAut.alertMessage, actionTitle: MapTextSection.checkUserAut.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    
    private func moveToCalendarView(model: FolderEntity) {
        
        let vc = CalendarMemoViewController(
            reactor: CalendarMemoViewReactor(folder: model)
        )
        
        vc.selectedLocationMemo = { [weak self] memo in
            guard let location = memo.location else { return }
            guard let location2D = self?.makeCLLocationCoordinate2D(lon: location.lon, lat: location.lat) else { return }
            
            self?.finduserAnnotationOrNew(CL2D: location2D)
        }
        
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .fullScreen
        present(nvc, animated: true)
    }
    
    private func settingPanel(view: UIViewController, layout: PanelLayoutType) -> FloatingPanelController{
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CustomAnnotation {
            var view: ArtWorkMarkerView? = mapView.dequeueReusableAnnotationView(withIdentifier: ArtWorkMarkerView.reusableIdentifier, for: annotation) as? ArtWorkMarkerView
    
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
            
            mainView.mapView.setCenter(annotaion.coordinate, animated: true)
            if let pending = pendingPanelConfiguration {
                pendingPanelConfiguration = nil
                showPanel(
                    coordinate: pending.coordinate,
                    viewType: pending.viewType,
                    layout: pending.layoutType
                )
                return
            }
            locationDetailModify(annotaion)
        } else {
            let clust = view.annotation
            if let location = clust?.coordinate {
                setRegion(location: location, latM: 300, longM: 300)
            }
        }
    }

    private func locationModify(_ anno: CustomAnnotation){
        if let memoId = anno.locationId {
            showPanel(
                coordinate: nil,
                viewType: .modify(memoId: memoId),
                layout: .custom
            )
        }
    }
    
    private func locationDetailModify(_ anno: CustomAnnotation){
        guard let id = anno.locationId else { return }
        print("Show Location Detail")
        showPanel(
            coordinate: nil,
            viewType: .about(memoId: id),
            layout: .detail
        )
    }
}


// MARK: SearchBar Logic
extension MapViewController {
    
    private func moveToSearchView() {
        let location = mainView.mapView.region.center
        
        let coordinate = CoordinateEntity(
            longitude: location.longitude,
            latitude: location.latitude
        )
        
        // 다음 뷰 컨트롤러로 이동하는 로직을 구현
        let searchViewController = SearchViewController(
            reactor: SearchReactor(coordinate: coordinate)
        )
        
        searchViewController.kakaoDataClosure = { [weak self] data in
            guard let self else { return }
            
            guard let location = makeCLLocationCoordinate2D(
                lon:data.x,
                lat:data.y
            ) else {
                return
            }
            
            removeAll()
            showPanel(
                coordinate: location,
                viewType: .addLocation,
                layout: .custom,
                configure: { viewController in
                    if let vc = viewController as? AddLocationMemoViewController {
                        vc.setKakaoData(data: data)
                    }
                }
            )
            addLongAnnotation(cl2: location)
        }
        
        searchViewController.modalPresentationStyle = .fullScreen
        
        present(searchViewController, animated: false)
    }
}

// MARK: 어노테이션
extension MapViewController {
    // 어노테이션 박아 -> 꺼내서 너가 수정해
    func addTestAnnotations() {
        removeAll()
        
        currentMemos.forEach { location in
            addCustomNoFocusForMemo(memo: location)
        }
    }
    
    // MARK: 메모를 통해 커스텀 어노테이션 설정
    func addCustomNoFocusForMemo(memo: LocationMemoEntity){
        let location = memo.location
        guard let location else { return }
        let cl2 = makeCLLocationCoordinate2D(lon: location.lon, lat: location.lat)
        print("????",memo.id)
        if let cl2 {
            let customLocation = CustomAnnotation(
                memoRegDate: memo.regDate,
                memoId: memo.id,
                title: memo.title,
                coordinate: cl2
            )
            mainView.mapView.addAnnotation(customLocation)
        }
    }
    
    // MARK: 롱프레스 하면 커스텀 어노테이션과 포커스
    func addLongAnnotation(cl2: CLLocationCoordinate2D){
        let anno = MKPointAnnotation()
        anno.coordinate = cl2
        let location = CustomAnnotation(memoRegDate: nil, memoId: nil, title: MapTextSection.noneName , coordinate: cl2, bool: true)
        mainView.mapView.addAnnotation(location)
        setRegion(location: location.coordinate,latM: 500,longM: 500)
        mainView.mapView.selectAnnotation(location, animated: true)
    }
    
    // MARK: 어노테이션 전부 지우기
    func removeAll(){
        let anotaions = mainView.mapView.annotations
        mainView.mapView.removeAnnotations(anotaions)
    }
}

extension MapViewController {

    // MARK: 로케이션 메모들 리스트 뷰 이동
    private func movetoLocationListView(){

        guard let folderId = UserDefaultsManager.currentFolderID else {
            return
        }
        guard let sharedEvent = reactor?.sharedEvent else { return }
        
        let vc = AllMemoLocationListViewController(
            reactor: AllLocationListViewReactor(
                folderID: folderId,
                sharedService: sharedEvent
            )
        )
        vc.delegate = self
        
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
}

// MARK: 판넬 뷰
extension MapViewController: FloatingPanelControllerDelegate {
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let locationInView = sender.location(in: mainView.mapView)
        let locationOnMap = mainView.mapView.convert(locationInView, toCoordinateFrom: mainView.mapView)
        
        removeAll()
        addTestAnnotations()
        showPanel(
            coordinate: locationOnMap,
            viewType: .addLocation,
            layout: .custom
        )
        addLongAnnotation(cl2: locationOnMap)
    }
    
    private func setupLongPressGesture() {
        let longTap = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        mainView.mapView.addGestureRecognizer(longTap)
    }
    
    private func setupSearchBarTap() {
        mainView.searchBar.addGestureRecognizer(searchBarTapGesture)
        if #available(iOS 13.0, *) {
            mainView.searchBar.searchTextField.isUserInteractionEnabled = false
        }
    }

    private func updateFloatingPanel(
        with configuration: PanelConfiguration,
        configure: ((UIViewController) -> Void)?
    ) {
        removeExistingPanelIfNeeded { [weak self] in
            self?.setupPanel(with: configuration, configure: configure)
        }
    }
    
    //MARK: 판넬 가기 설정
    private func setupPanel(
        with configuration: PanelConfiguration,
        configure: ((UIViewController) -> Void)?
    ) {
        guard let currentFolderID = UserDefaultsManager.currentFolderID else { return }
        
        let viewController: UIViewController
        
        switch configuration.viewType {
        case .addLocation:
            guard let sharedEvent = reactor?.sharedEvent else { return }
            let vc = AddLocationMemoViewController(
                reactor: MemoAddReactor(sharedService: sharedEvent)
            )
            
            if let coordinate = configuration.coordinate {
                let coordinateStruct = AddModelEntity(
                    lat: String(coordinate.latitude),
                    lon: String(coordinate.longitude),
                    folder: currentFolderID
                )
                vc.setAddModel(model: coordinateStruct)
            }
            vc.backDelegate = self
            viewController = vc
            
        case let .about(memoID):
            guard let sharedEvent = reactor?.sharedEvent else { return }
            
            let vc = AboutLocationViewController(
                reactor: AboutLocationReactor(
                    memoID: memoID,
                    shared: sharedEvent
                )
            )
            vc.backDelegate = self
            vc.locationDelegate = self
            viewController = vc
            
        case let .modify(memoID):
            guard let sharedEvent = reactor?.sharedEvent else { return }
            let vc = AddLocationMemoViewController(
                reactor: MemoAddReactor(sharedService: sharedEvent)
            )
            
            if let coordinate = configuration.coordinate {
                let coordinateStruct = AddModelEntity(
                    lat: String(coordinate.latitude),
                    lon: String(coordinate.longitude),
                    folder: currentFolderID
                )
                vc.setAddModel(model: coordinateStruct)
            }
            vc.backDelegate = self
            vc.setModifier(memoID: memoID)
            
            viewController = vc
        }
        
        configure?(viewController)
        let newPanel = settingPanel(
            view: viewController,
            layout: configuration.layoutType
        )
        if let vc = viewController as? AboutLocationViewController {
            vc.mainView.collectionView.alwaysBounceVertical = true
            newPanel.track(scrollView: vc.mainView.collectionView)
        }
        
        newPanel.move(to: .half, animated: true)
        floatPanel = newPanel
    }
    
    private func showPanel(
        coordinate: CLLocationCoordinate2D?,
        viewType: PanelViewControllerType,
        layout: PanelLayoutType,
        configure: ((UIViewController) -> Void)? = nil
    ) {
        guard let folderID = UserDefaultsManager.currentFolderID else { return }
        let config = PanelConfiguration(
            coordinate: coordinate,
            viewType: viewType,
            layoutType: layout,
            folderID: folderID,
        )
        updateFloatingPanel(with: config, configure: configure)
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
        floatPanel?.removePanelFromParent(animated: true) { [weak self] in
            guard let self else {return}
            
            floatPanel = nil
            addTestAnnotations()
        }
        removeAll()
    }
}
// MARK: 로케이션 수정
extension MapViewController: AboutModifyLocationDelegate {
    
    func getModifyInfo(with locationMemo: LocationMemoEntity) {
        let coordinate: CLLocationCoordinate2D?
        if let location = locationMemo.location {
            coordinate = makeCLLocationCoordinate2D(lon: location.lon, lat: location.lat)
        } else {
            coordinate = nil
        }
        requestModifyPanel(memoId: locationMemo.id, coordinate: coordinate)
    }
}


extension MapViewController: AllMemoLocationListViewControllerDelegate {
    
    func modifyRequest(memoLocation: LocationMemoEntity) {
        let coordinate: CLLocationCoordinate2D?
        if let location = memoLocation.location {
            coordinate = makeCLLocationCoordinate2D(lon: location.lon, lat: location.lat)
        } else {
            coordinate = nil
        }
        requestModifyPanel(memoId: memoLocation.id, coordinate: coordinate)
    }
}

extension MapViewController {
    
    @discardableResult
    func finduserAnnotationOrNew(CL2D: CLLocationCoordinate2D) -> Bool {
        // where First 순회 조건 참조
        let userAnnotation = mainView.mapView.annotations.first { [weak self ] annotation in
            guard self != nil else { return false }
            
            guard let annotation = annotation as? CustomAnnotation else { return false }
            
            return annotation.coordinate.latitude == CL2D.latitude && annotation.coordinate.longitude == CL2D.longitude
            
        }
        guard let custom  = userAnnotation as? CustomAnnotation else { return false }
        mainView.mapView.selectAnnotation(custom, animated: true)
        return true
    }
    
    private func requestModifyPanel(
        memoId: String,
        coordinate: CLLocationCoordinate2D?
    ) {
        guard let folderID = UserDefaultsManager.currentFolderID else { return }
        let config = PanelConfiguration(
            coordinate: coordinate,
            viewType: .modify(memoId: memoId),
            layoutType: .custom,
            folderID: folderID
        )
        pendingPanelConfiguration = config
        
        if let coordinate {
            setRegion(location: coordinate, latM: 300, longM: 300)
            
            if let existing = findAnnotation(memoId: memoId, coordinate: coordinate) {
                if mainView.mapView.selectedAnnotations.contains(where: { $0 === existing }) {
                    showPanel(
                        coordinate: coordinate,
                        viewType: .modify(memoId: memoId),
                        layout: .custom
                    )
                    pendingPanelConfiguration = nil
                } else {
                    mainView.mapView.selectAnnotation(existing, animated: true)
                }
                return
            }
        }
        
        showPanel(
            coordinate: coordinate,
            viewType: .modify(memoId: memoId),
            layout: .custom
        )
        pendingPanelConfiguration = nil
    }
    
    private func findAnnotation(
        memoId: String,
        coordinate: CLLocationCoordinate2D
    ) -> CustomAnnotation? {
        mainView.mapView.annotations
            .compactMap { $0 as? CustomAnnotation }
            .first { annotation in
                annotation.locationId == memoId
                || (annotation.coordinate.latitude == coordinate.latitude
                    && annotation.coordinate.longitude == coordinate.longitude)
            }
    }
    
    func makeCLLocationCoordinate2D(
        lon: String,
        lat: String
    ) -> CLLocationCoordinate2D? {
        
        let dbLat = Double(lat)
        let dbLon = Double(lon)
        
        if let dbLat,
           let dbLon {
            return CLLocationCoordinate2D(latitude: dbLat, longitude: dbLon)
        } else {
            return nil
        }
    }
}
