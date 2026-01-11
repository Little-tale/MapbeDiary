//
//  MapViewStackButtonView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import SnapKit

class MapViewStackButtonView: UIStackView {
    
    let userLocationButton = CustomLocationButton(frame: .zero, imageType: .location)
    let locationMemosButton = CustomLocationButton(frame: .zero, imageType: .AllMemo)
    let settingButton = CustomLocationButton(frame: .zero, imageType: .setting)
    let calendarButton = CustomLocationButton(frame: .zero, imageType: .calendarButton)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHirachy()
        setupUI()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        configureHirachy()
        setupUI()
    }
    
    // 회고 -> 이걸로 순서를 바꾸어야 진짜 바뀜
    private func configureHirachy(){
        addArrangedSubview(settingButton)
        addArrangedSubview(calendarButton)
        addArrangedSubview(locationMemosButton)
        addArrangedSubview(userLocationButton)
    }
    
    private func setupUI(){
        axis = .vertical
        distribution = .equalSpacing
        spacing = 25
        
        [userLocationButton, locationMemosButton,settingButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        }
        
    }
    
}
