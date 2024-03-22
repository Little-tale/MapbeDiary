//
//  OnboardBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/22/24.
//

import UIKit
import SnapKit

class OnboardBaseView: BaseView {
    let imageSliderView = ScrollImageView(frame: .zero)
    let startButton = UIButton()
    
    override func configureHierarchy() {
        addSubview(imageSliderView)
        addSubview(startButton)
    }

    override func configureLayout() {
        imageSliderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        startButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(25)
        }
    }
    
    override func designView() {
        var configu = UIButton.Configuration.bordered()
        configu.title = "시작하기"
        configu.baseBackgroundColor = .wheetOrange
        configu.baseForegroundColor = .wheetBior
        configu.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ attri in
            var custom = attri
            custom.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            return custom
        })
        startButton.configuration = configu
    }
}
