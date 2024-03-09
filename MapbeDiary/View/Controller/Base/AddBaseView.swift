//
//  AddBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import UIKit
import SnapKit

final class AddBaseView: BaseView {
    private let backView = UIView()
    let AddTitleDateView = AddTitleDateImageView()
    
    let phonNumberLabel: UILabel = {
       let view = UILabel()
        view.text = "전화번호"
        view.textColor = .black
        view.font = .systemFont(ofSize: 12, weight: .black)
        return view
    }()
    
    let phoneTextField = UITextField(frame: .zero)
    
    let stackView: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 10
        view.alignment = .center
        return view
    }()
    
    override func configureHierarchy() {
        self.addSubview(backView)
        backView.addSubview(AddTitleDateView)
        backView.addSubview(stackView)
        stackView.addArrangedSubview(phonNumberLabel)
        stackView.addArrangedSubview(phoneTextField)
    }
    
    override func configureLayout() {
        backView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        AddTitleDateView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(110)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(UIScreen.main.bounds.width * 0.7)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.top.equalTo(AddTitleDateView.snp.bottom).offset(8)
        }
        
    }
    
    override func designView() {
        backView.layer.cornerRadius = 24
        backView.backgroundColor = .white
        phoneTextField.backgroundColor = .red
        phoneTextField.addLeftPadding(width: 12)
        phonNumberLabel.textAlignment = .center
    }
}
