//
//  MemoAddVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit
import SnapKit

final class MemoAddVCView: VCBaseView {
    
    private let backView = UIView()
    
    let AddTitleDateView = AddTitleDateImageView()
    
    let folderButton = UIButton().after {
        var config = UIButton.Configuration.tinted()
        config.imagePadding = 8
        config.baseForegroundColor = .wheetBlack
        config.title = MapTextSection.beginningSoon
        let image = UIImage(named: ImageSection.defaultFolderImage.rawValue)!.resizeImage(maxDimension: 20)
        config.image = image
        $0.configuration = config
        
    }
    
    let saveButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .wheetBlack
        config.title = MapTextSection.saveTitle
        $0.configuration = config
    }
    
    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .wheetBlack
        $0.configuration = config
    }
    
    let phoneNumberLabel = UILabel().after {
        $0.text = AddViewSection.phoneNumberTextLabel.placeHolder
        $0.textColor = .black
        $0.font = JHFont.UIKit.bo12
    }
    
    let phoneTextField = UITextField(frame: .zero)
    
    
    override func setupHierarchy() {
        addSubview(saveButton)
        addSubview(backButton)
        addSubview(backView)
        backView.addSubview(AddTitleDateView)
        backView.addSubview(phoneNumberLabel)
        backView.addSubview(phoneTextField)
        backView.addSubview(folderButton)
    }
    
    override func setupConstraints() {
        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
        }
        
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.top.equalTo(backButton.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
        AddTitleDateView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(AddTitleDateView.snp.bottom).offset(8)
            make.height.equalTo(38)
            make.leading.equalTo(AddTitleDateView.titleTextField.snp.leading)
            make.trailing.equalToSuperview().inset(12)
        }
        
        phoneNumberLabel.snp.makeConstraints { make in
            make.centerY.equalTo(phoneTextField)
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalTo(phoneTextField.snp.leading)
        }
        
        folderButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(8)
            make.trailing.equalTo(phoneTextField)
            make.height.equalTo(30)
        }
    }
    
    override func setupUI() {
        backView.layer.cornerRadius = 24
        backView.backgroundColor = .wheetLightBrown

        phoneNumberLabel.textAlignment = .center
        
        phoneTextField.addLeftPadding(width: 12)
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.placeholder = AddViewSection.phoneNuberTextField.placeHolder
        phoneTextField.setPlaceholderColor(.black)
        phoneTextField.backgroundColor = .wheetSideBrown
        phoneTextField.textAlignment = .center
        
        phoneTextField.keyboardType = .numberPad
    }
}
