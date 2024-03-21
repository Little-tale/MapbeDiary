//
//  SettingWebViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit

class SettingWebViewController: BaseHomeViewController<WebHomeView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
}

extension SettingWebViewController {
    private func subscribe(){
        homeView.viewModel.outputNaviTitle.bind { [weak self] title in
            guard let title else { return }
            self?.navigationItem.title = title
        }
    }
}
