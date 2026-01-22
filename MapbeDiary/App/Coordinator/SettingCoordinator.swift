//
//  SettingCoordinator.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/23/26.
//

import UIKit

@MainActor
final class SettingCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private(set) var navigationController: UINavigationController?

    init(parentCoordinator: Coordinator? = nil) {
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        let vc = SettingViewController(
            reactor: SettingViewReactor(),
            coordinator: self
        )
        let nav = UINavigationController(rootViewController: vc)
        
        nav.setNavigationBarHidden(true, animated: false)
        navigationController = nav
    }
}
