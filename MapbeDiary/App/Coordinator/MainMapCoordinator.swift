import UIKit

@MainActor
final class MainMapCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator? = nil
    var childCoordinators: [Coordinator] = []
    private(set) var navigationController: UINavigationController?
    
    private let window: UIWindow
    private let sharedEventService: SharedEventService
    
    init(
        window: UIWindow,
        sharedEventService: SharedEventService
    ) {
        self.window = window
        self.sharedEventService = sharedEventService
    }
    
    func start() {
        let vc = MapViewController(
            reactor: MapViewReactor(
                sharedEvent: sharedEventService,
                locationManager: LocationManager()
            ),
            coordinator: self
        )
        let nav = UINavigationController(rootViewController: vc)
        
        nav.setNavigationBarHidden(true, animated: false)
        navigationController = nav
        window.rootViewController = nav
    }
}
