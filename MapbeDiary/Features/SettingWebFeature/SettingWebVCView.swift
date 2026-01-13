//
//  SettingWebVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit
import WebKit
import SnapKit

final class SettingWebVCView: VCBaseView {
    let webView = WKWebView()
    
    override func setupHierarchy() {
        addSubview(webView)
    }
    
    override func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func setupUI() {
        backgroundColor = .white
    }
}
