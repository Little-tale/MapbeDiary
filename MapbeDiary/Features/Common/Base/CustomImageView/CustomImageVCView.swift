//
//  CustomImageVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit
import SnapKit

final class CustomImageVCView: VCBaseView {
    
    let scrollView = UIScrollView().after {
        $0.maximumZoomScale = 3.0
        $0.minimumZoomScale = 0.8
        $0.bouncesZoom = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .black
    }

    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName:"chevron.backward")
        config.baseForegroundColor = .white
        $0.configuration = config
    }
    
    let imageView = UIImageView().after {
        $0.contentMode = .scaleAspectFit
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(backButton)
        addSubview(activityIndicator)
    }
    
    override func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(safeAreaLayoutGuide).offset(10)
            make.size.equalTo(40)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
    }
    
    private func animate() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            options: .curveEaseInOut
        ) { [weak self] in
            guard let self else { return }
            imageView.frame = scrollView.bounds
            scrollView.contentSize = scrollView.bounds.size
        }
    }
}

extension CustomImageVCView {
    
    func activityAnimation(isOn: Bool) {
        if isOn {
            activityIndicator.startAnimating()
        }
        activityIndicator.stopAnimating()
    }
    
    func loadImage(data: Data) {
        imageView.image = UIImage(data: data)
        activityAnimation(isOn: false)
        activityIndicator.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { [weak self] in
            self?.animate()
        }
    }
}
