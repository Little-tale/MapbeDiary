//
//  MapViewStackButtonView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import SnapKit

class MapViewStackButtonView: UIStackView {
    
    let userLocationButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = .userLocation.resizeImage(maxDimension: 40)
        
        $0.configuration = config
        $0.backgroundColor = .white
        $0.configurationUpdateHandler = { button in
            if button.state == .highlighted {
                button.alpha = 0.6
            } else {
                button.alpha = 1
            }
        }
    }
    
    let locationMemosButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = .memoAsset.resizeImage(maxDimension: 50)
        
        $0.configuration = config
        $0.backgroundColor = .white
        $0.configurationUpdateHandler = { button in
            if button.state == .highlighted {
                button.alpha = 0.6
            } else {
                button.alpha = 1
            }
        }
    }
    
    let settingButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = .setting3D.resizeImage(maxDimension: 50)
        
        $0.configuration = config
        $0.backgroundColor = .white
        $0.configurationUpdateHandler = { button in
            if button.state == .highlighted {
                button.alpha = 0.6
            } else {
                button.alpha = 1
            }
        }
    }

    
    let calendarButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = .calendar3D.resizeImage(maxDimension: 40)
        
        $0.configuration = config
        $0.backgroundColor = .white
        $0.configurationUpdateHandler = { button in
            if button.state == .highlighted {
                button.alpha = 0.6
            } else {
                button.alpha = 1
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    private func setupHierarchy() {
        addArrangedSubview(settingButton)
        addArrangedSubview(calendarButton)
        addArrangedSubview(locationMemosButton)
        addArrangedSubview(userLocationButton)
    }
    
    private func setupConstraints(){
        [
            settingButton,
            calendarButton,
            locationMemosButton,
            userLocationButton,
        ].forEach { button in
            button.snp.makeConstraints { make in
                make.size.equalTo(50)
            }
            button.layer.masksToBounds = true
            button.clipsToBounds = true
            button.layer.cornerRadius = 50
        }
    }
    
    private func setupUI(){
        axis = .vertical
        distribution = .equalSpacing
        spacing = 25
    }
}
