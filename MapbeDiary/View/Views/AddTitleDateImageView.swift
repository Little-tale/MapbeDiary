//
//  AddBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import SnapKit


final class AddTitleDateImageView: BaseView {
    private let emptyView = UIView()
    let titleTextField = UITextField(frame: .zero)
    let imageView = circleImageView(frame: .zero)
    let simpleMemoTextField = UITextField(frame: .zero)
    let dateLabel = UILabel()
    
    override func configureHierarchy() {
        self.addSubview(emptyView)
        emptyView.addSubview(titleTextField)
        emptyView.addSubview(imageView)
        emptyView.addSubview(simpleMemoTextField)
        emptyView.addSubview(dateLabel)
    }
    override func configureLayout() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(10)
            make.size.equalTo(60)
        }
        titleTextField.snp.makeConstraints{ make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset( 10 )
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(38)
        }
        simpleMemoTextField.snp.makeConstraints{ make in
            make.leading.trailing.equalTo(titleTextField)
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(simpleMemoTextField)
            make.top.equalTo(simpleMemoTextField.snp.bottom).offset(4)
        }
    }
    
    override func designView() {
        // emptyView.backgroundColor = .brown
        placeHolderSetting()
        imageView.backgroundColor = .darkGray
        titleTextField.backgroundColor = .systemGray6
        simpleMemoTextField.backgroundColor = .systemGray6
        
        titleTextField.textAlignment = .center
        simpleMemoTextField.textAlignment = .center
        layerSetting()
    }
    
    private func placeHolderSetting(){
        
        titleTextField.placeholder = AddViewSection.titleTextFieldText.placeHolder
        
        titleTextField.setPlaceholderColor(.black)
        
        simpleMemoTextField.placeholder = AddViewSection.simpleMemoTextFiled.placeHolder
        
        simpleMemoTextField.setPlaceholderColor(.black)
    }
    private func layerSetting() {
        titleTextField.layer.cornerRadius = 12
        simpleMemoTextField.layer.cornerRadius = 12
        dateLabel.font = .systemFont(ofSize: 12, weight: .light)
    }
}
