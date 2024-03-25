//
//  SettingWebViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit

class SettingWebViewController: BaseHomeViewController<WebHomeView> {
    
    var indicator: CustomIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        startSetting()
    }
    
    private func startSetting(){
        indicator = CustomIndicator(view: homeView, navigationController: navigationController, tabBarController: nil)
        DispatchQueue.main.async {
            [weak self] in
            self?.indicator?.showActivityIndicator(title: "Web_Staring".localized)
        }
    }
}

extension SettingWebViewController {
    private func subscribe(){
        homeView.viewModel.outputNaviTitle.bind { [weak self] title in
            guard let title else { return }
            self?.navigationItem.title = title
        }
        homeView.viewModel.webLoadCompilte.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            indicator?.stopActivity()
        }
    }
    
}
