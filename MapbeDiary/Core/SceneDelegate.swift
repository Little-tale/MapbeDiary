//
//  SceneDelegate.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

   
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        // MARK: 아이큐 키보드
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        // let navigationController = UINavigationController(rootViewController: MapViewController())
        NetWorkServiceMonitor.shared.startMonitor() // 네트워크 상태 감시
        let repository = RealmRepository()
        if let folder = repository.findAllFolderArray().first {
            print("Widget : 제발1 ")
            SingleToneDataViewModel.shared.shardFolderOb.value = folder
            let vc = MapViewController()
            if let url =  connectionOptions.urlContexts.first?.url {
                vc.ifURL = url.absoluteString
            }
            window?.rootViewController = MapViewController()
            //CalenderMemoViewController()
            window?.makeKeyAndVisible()
            
        } else {
            window?.rootViewController = OnboardViewController()
            window?.makeKeyAndVisible()
        }
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
                return
        }
        print("openURLContexts",url)
        NotificationCenter.default.post(name: .getWidget, object: url.description)
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
