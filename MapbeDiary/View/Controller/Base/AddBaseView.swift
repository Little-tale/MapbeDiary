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
    let folderButton: UIButton = {
       let view = UIButton()
        var configu = UIButton.Configuration.tinted()
        configu.image = UIImage(named: "defaultFolderImage")?.resizeImage(newWidth: 30)
        configu.imagePadding = 8
        view.configuration = configu
        return view
    }()
    
    let phonNumberLabel: UILabel = {
       let view = UILabel()
        view.text = AddViewSection.phoneNumberTextLabel.placeHolder
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
        backView.addSubview(folderButton)
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
            make.width.equalTo(140)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.top.equalTo(AddTitleDateView.snp.bottom).offset(8)
        }
        folderButton.snp.makeConstraints { make in
            make.trailing.equalTo(stackView.snp.trailing)
            make.top.equalTo(stackView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        phoneTextField.snp.updateConstraints { make in
            make.width.equalTo(self.frame.width * 0.7)
        }
        layoutIfNeeded()
    }
    
    override func designView() {
        backView.layer.cornerRadius = 24
        backView.backgroundColor = .white
        phoneTextField.backgroundColor = .red
        phoneTextField.addLeftPadding(width: 12)
        phonNumberLabel.textAlignment = .center
        
        AddTitleDateView.imageView.image = UIImage(named: ImageSection.defaultMarkerImage.rawValue)
        
    }
}
