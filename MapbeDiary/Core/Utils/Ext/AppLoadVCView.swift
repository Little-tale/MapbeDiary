//
//  AppLoadVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit
import SnapKit

final class AppLoadVCView: VCBaseView {
    
    private let imageView = UIImageView().after {
        $0.image = UIImage(resource: .mb3)
        $0.contentMode = .scaleAspectFill
    }
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large).after { $0.startAnimating() }
    
    override func setupHierarchy() {
        addSubview(imageView)
        addSubview(activityIndicatorView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
