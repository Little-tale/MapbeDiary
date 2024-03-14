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
    let folderButton: UIButton = CustomButton.folderButton()
    let viewModel = TextFiledTesterViewModel()
    
    let saveButton: UIButton = {
        let view = UIButton()
        var configu = UIButton.Configuration.plain()
        configu.title = "저장" 
        view.configuration = configu
        return view
    }()
    
    let backButton: UIButton = {
        let view = UIButton()
        var configu = UIButton.Configuration.plain()
        configu.image = UIImage(systemName: "chevron.backward")
        view.configuration = configu
        return view
    }()
    
    
    let phonNumberLabel: UILabel = {
       let view = UILabel()
        view.text = AddViewSection.phoneNumberTextLabel.placeHolder
        view.textColor = .black
        view.font = JHFont.UIKit.bo12
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
    
    lazy var textFieldList = [AddTitleDateView.titleTextField, AddTitleDateView.simpleMemoTextField, phoneTextField]
    
    override func configureHierarchy() {
        addSubview(saveButton)
        addSubview(backButton)
        self.addSubview(backView)
        backView.addSubview(AddTitleDateView)
        backView.addSubview(stackView)
        stackView.addArrangedSubview(phonNumberLabel)
        stackView.addArrangedSubview(phoneTextField)
        backView.addSubview(folderButton)
        
    }
    
    override func configureLayout() {
        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
        }
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
        }
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.bottom.equalToSuperview()
        }
        
        AddTitleDateView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(backView)
            make.height.equalTo(110)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(140)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(backView).inset(12)
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
            make.width.equalTo(self.frame.width * 0.75)
        }
        layoutIfNeeded()
    }
    
    override func designView() {
        textFieldSetting()

        backView.layer.cornerRadius = 24
        backView.backgroundColor = .white
        
        phonNumberLabel.textAlignment = .center
        
        AddTitleDateView.imageView.image = UIImage(named: ImageSection.defaultMarkerImage.rawValue)
        
        textFieldTester()
    }
    
    private func textFieldSetting(){
        phoneTextField.backgroundColor = .red
        phoneTextField.addLeftPadding(width: 12)
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.backgroundColor = .systemGray5
        phoneTextField.placeholder = AddViewSection.phoneNuberTextField.placeHolder
        phoneTextField.setPlaceholderColor(.black)
        
        var tag = 0
        textFieldList.forEach { [weak self] textfield in
            guard self != nil else { return }
            textfield.tag = tag
            tag += 1
        }
    }
    
    private func textFieldTester(){
        textFieldList.forEach { [weak self] textfield in
            guard let self else { return }
            textfield.delegate = self
        }
    }
}

extension AddBaseView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        let inputModel = TextViewModel(text: text, rangeStart: range.location, rangeLength: range.length, replacing: string)
        
        switch textField.tag {
        case 0:
            viewModel.titleTester.value = inputModel
        case 1:
            viewModel.simpleMemoTester.value = inputModel
        case 2:
            viewModel.phoneTextTester.value = inputModel
        default: break
        }
        return viewModel.canAllowed.value
    }
}
