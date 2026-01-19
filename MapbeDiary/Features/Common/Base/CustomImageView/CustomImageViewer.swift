//
//  CustomImageViewer.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit
import SnapKit

final class CustomImageViewer: BaseHomeViewController<CustomImageVCView> {
    
    override func register() {
        settingBackButtonAction()
    }
    
    func loadImage(data: Data) {
        homeView.scrollView.delegate = self
        homeView.loadImage(data: data)
    }
}

extension CustomImageViewer {
    private func settingBackButtonAction() {
        let action = UIAction.guardSelf(self) { owner, _ in
            owner.dismiss(animated: true)
        }
        
        homeView.backButton.addAction(action, for: .touchUpInside)
    }
}

extension CustomImageViewer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        homeView.imageView
    }
}
