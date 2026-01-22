//
//  SettingWebViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class SettingWebViewController: ReactorBaseViewController<SettingWebReactor, SettingWebVCView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSetting()
    }
    
    override func register() {
        mainView.webView.navigationDelegate = self
    }
    
    override func bind(reactor: SettingWebReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .map { $0.navigationTitle }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                owner.navigationItem.title = text
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.webUrlRequest }
            .bind(with: self) { owner, request in
                owner.mainView.webView.load(request)
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: SettingWebReactor) {
        rx.viewDidLoad
            .map { _ in SettingWebReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.navigationController?.setNavigationBarHidden(false, animated: true)
            }
            .disposed(by: disposeBag)
        
        rx.viewWillDisappear
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.navigationController?.setNavigationBarHidden(true, animated: false)
            }
            .disposed(by: disposeBag)
    }
}

extension SettingWebViewController {
    
    func sendAction(type: SettingActionType) {
        reactor?.action.onNext(.setAction(type))
    }
    
    private func startSetting() {
        LoadingWindow.shared.show(title: "Web_Staring".localized)
    }
}

// MARK: WKNavigationDelegate
extension SettingWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingWindow.shared.hide()
    }
}
