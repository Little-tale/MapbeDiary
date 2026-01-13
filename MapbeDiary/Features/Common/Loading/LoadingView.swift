//
//  LoadingView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit
import SnapKit

final class LoadingView: VCBaseView {
    
    // MARK: Property (Private)
    
    private let backGroundView = UIView()
    private let activityIndicator = UIView()
    private let activityView = UIActivityIndicatorView()
    private let loadingTextLabel = UILabel()
    
    
    override func setupHierarchy() {
        addSubview(backGroundView)
        backGroundView.addSubview(activityIndicator)
        activityIndicator.addSubview(activityView)
        activityIndicator.addSubview(loadingTextLabel)
    }
    
    override func setupConstraints() {
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 150, height: 150))
            make.center.equalToSuperview()
        }
        activityView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        loadingTextLabel.snp.makeConstraints { make in
            make.top.equalTo(activityView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    override func setupUI() {
        backGroundView.backgroundColor = .white.withAlphaComponent(0.2)
        
        activityIndicator.backgroundColor = .wheetSideBrown
        
        activityView.hidesWhenStopped = true
        activityView.style = .large
        activityView.color = .wheetPink
        
        loadingTextLabel.textColor = .wheetDarkBrown
        loadingTextLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
}

extension LoadingView {
    
    func setTitle(_ text: String) {
        loadingTextLabel.text = text
    }
    
    func startAnimating() {
        activityView.startAnimating()
    }
    
    func stopAnimating() {
        activityView.stopAnimating()
    }
}
