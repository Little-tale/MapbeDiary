//
//  WebHomeView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import SnapKit
import WebKit

class WebHomeView: BaseView{
    let webView = WKWebView()
    
    let viewModel = SettingWebViewModel()
    
    override func configureHierarchy() {
        addSubview(webView)
    }
    
    override func configureLayout() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func register() {
        webView.navigationDelegate = self
    }
    
    // MARK: 회고
    override func subscribe() {
        viewModel.outputURL.bind { [weak self] urlRequest in
            guard let self else { return }
            guard let urlRequest else { return }
            
            webView.allowsBackForwardNavigationGestures = true
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            // 회고
            DispatchQueue.main.async {
                [weak self] in guard let self else { return }
                webView.load(urlRequest)
            }
        }
    }
    deinit {
        print("deinit - WebHomeView")
    }
}

// 회고 ->
extension WebHomeView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.webLoadCompilte.value = ()
    }
}
