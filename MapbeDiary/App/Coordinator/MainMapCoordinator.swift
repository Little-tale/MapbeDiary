import UIKit

@MainActor
final class MainMapCoordinator: Coordinator {
    
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
            )
        )
        let nav = UINavigationController(rootViewController: vc)
        
        nav.setNavigationBarHidden(true, animated: false)
        setAction(from: vc)
        navigationController = nav
        window.rootViewController = nav
    }
}

extension MainMapCoordinator {
    private func setAction(from vc: MapViewController) {
        vc.delegateCloser = { [weak self] action in
            guard let self else { return }
            switch action {
            case let .moveToAnimationPresent(vc, target):
                moveAnimation(vc: vc, target: target)
            }
        }
    }
    
    
    private func moveAnimation(vc: UIViewController, target: UIView) {
        if #available(iOS 18.0, *) {
            vc.preferredTransition = .zoom { [weak target] context in
                return target
            }
            navigationController?.present(vc, animated: true)
            return
        }
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: false)
    }
}
