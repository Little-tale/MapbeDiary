//
//  AddImageWithButtonView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit
import SnapKit

final class AddImageWithButtonView: BaseView {
    
    let imageView = circleImageView(frame: .zero)
    
    let imageChangeButton = UIButton().after {
        var config = UIButton.Configuration.tinted()
        config.title = AddViewSection.changeButtonTitle
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer{ atrubute in
            var before = atrubute
            before.font = JHFont.UIKit.bo10
            return before
        }
        $0.configuration = config
    }
    
    override func configureHierarchy() {
        addSubview(imageView)
        addSubview(imageChangeButton)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(60)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        imageChangeButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalToSuperview()
        }
    }
    
    override func designView() {
        imageView.contentMode = .scaleAspectFill
    }
}
