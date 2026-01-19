import UIKit
import IQKeyboardManagerSwift

@MainActor
final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    private let window: UIWindow
    private let sharedService: SharedEventService
    private var mainMapCoordinator: MainMapCoordinator?
    
    init(
        window: UIWindow,
        sharedEventService: SharedEventService = SharedEventService()
    ) {
        self.window = window
        self.sharedService = sharedEventService
    }
    
    func start() {
        configureServices()
        window.rootViewController = AppLoadViewController()
        
        Task { @MainActor in
            do {
                guard let _ = try await FolderRealmRepository.shared.fineAllFolder().first else {
                    throw NSError(domain: "NoFolder", code: 0)
                }
                startMainMap()
            } catch {
                startOnboard()
            }
        }
    }
    
    func handleWidgetActionIfNeeded() {
        guard let defaults = UserDefaults(suiteName: WidgetAction.widgetAppGroup) else { return }
        
        guard let action = defaults.string(
            forKey: WidgetAction.search.actionKey
        ) else { return }
        
        defaults.removeObject(forKey: WidgetAction.search.actionKey)
        
        if action == WidgetAction.search.action {
            sharedService.send(.widgetAction(.search))
        }
    }
    
    func handleDeepLink(_ url: URL) {
        if url.absoluteString == WidgetAction.search.path {
            sharedService.send(.widgetAction(.search))
            return
        }
        
        guard url.scheme == "widget" else { return }
        if url.host?.lowercased() == "search" {
            sharedService.send(.widgetAction(.search))
        }
    }
}

private extension AppCoordinator {
    func startMainMap() {
        let coordinator = MainMapCoordinator(
            window: window,
            sharedEventService: sharedService
        )
        mainMapCoordinator = coordinator
        childCoordinators = [coordinator]
        coordinator.start()
    }
    
    func startOnboard() {
        let vc = OnboardViewController(
            reactor: OnboardReactor(sharedEvent: sharedService)
        )
        vc.onFinish = { [weak self] _ in
            self?.startMainMap()
        }
        window.rootViewController = vc
    }
    
    func configureServices() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        NetWorkServiceMonitor.shared.startMonitor()
        
        let _ = RealmActor.shared
        Task {
            let _ = await FolderRealmRepository.shared.setUp()
        }
    }
}
