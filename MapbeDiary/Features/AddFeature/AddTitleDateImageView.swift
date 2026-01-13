//
//  AddBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import SnapKit


final class AddTitleDateImageView: BaseView {

    let addImageWithButtonView = AddImageWithButtonView()
    let titleTextField = UITextField(frame: .zero)
    let simpleMemoTextField = UITextField(frame: .zero)
    let dateLabel = UILabel()
    

    override func configureHierarchy() {
        addSubview(titleTextField)
        addSubview(addImageWithButtonView)
        addSubview(simpleMemoTextField)
        addSubview(dateLabel)
    }
    override func configureLayout() {
        
        addImageWithButtonView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        titleTextField.snp.makeConstraints{ make in
            make.leading.equalTo(addImageWithButtonView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset( 10 )
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(38)
        }
        
        simpleMemoTextField.snp.makeConstraints{ make in
            make.leading.trailing.equalTo(titleTextField)
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.height.equalTo(38)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(simpleMemoTextField)
            make.top.equalTo(simpleMemoTextField.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
    }
    
    override func designView() {
        setTitleTextFieldUI()
        setSimpleMemoTextFieldUI()
        layerSetting()
        setDefaultImage()
    }
    
    private func setTitleTextFieldUI() {
        titleTextField.textAlignment = .center
        titleTextField.placeholder = AddViewSection.titleTextFieldText.placeHolder
        // MapTextSection.emptyTitleTextFieldPlaceHolder
        titleTextField.setPlaceholderColor(.black)
    }
    
    private func setSimpleMemoTextFieldUI() {
        simpleMemoTextField.textAlignment = .center
        simpleMemoTextField.placeholder = AddViewSection.simpleMemoTextFiled.placeHolder
        
        simpleMemoTextField.setPlaceholderColor(.black)
        
        [simpleMemoTextField, titleTextField].forEach { textField in
            textField.backgroundColor = .wheetSideBrown
        }
    }

    private func layerSetting() {
        titleTextField.layer.cornerRadius = 12
        simpleMemoTextField.layer.cornerRadius = 8
        dateLabel.font = .systemFont(ofSize: 12, weight: .light)
    }
    
    private func setDefaultImage() {
        let value = ImageSection.defaultMarkerImage.rawValue
        addImageWithButtonView.imageView.image = UIImage(named: value)
    }

}
