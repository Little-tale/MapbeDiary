//
//  SceneDelegate.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import AppIntents

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let sharedService = SharedEventService()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        // MARK: 아이큐 키보드
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        // let navigationController = UINavigationController(rootViewController: MapViewController())
        NetWorkServiceMonitor.shared.startMonitor() // 네트워크 상태 감시
        
        let _ = RealmActor.shared
        // MARK: Realm Setting
        Task {
            let _ = await FolderRealmRepository.shared.setUp()
        }
        
        // FIXME: - 불러오는 동안의 뷰가 필요함.
        Task { @MainActor in
            do {
                guard let _ = try await FolderRealmRepository.shared.fineAllFolder().first else {
                    throw NSError()
                }
                
                let vc = MapViewController(
                    reactor: MapViewReactor(
                        sharedEvent: sharedService,
                        locationManager: LocationManager()
                    )
                )
            
                window?.rootViewController = vc
                
            } catch {
                goOnboard()
            }
        }
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }
        window?.makeKeyAndVisible()
    }
    
    
    private func goOnboard() {
        window?.rootViewController = OnboardViewController(
            reactor: OnboardReactor(sharedEvent: sharedService)
        )
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url)
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        handleWidgetActionIfNeeded()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        handleWidgetActionIfNeeded()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func handleWidgetActionIfNeeded() {
        guard let defaults = UserDefaults(suiteName: WidgetAction.widgetAppGroup) else { return }
        
        guard let action = defaults.string(
            forKey: WidgetAction.search.actionKey
        ) else { return }
        
        defaults.removeObject(forKey: WidgetAction.search.actionKey)
        
        if action == WidgetAction.search.action {
            sharedService.send(.widgetAction(.search))
        }
    }
    
    private func handleDeepLink(_ url: URL) {
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
