//
//  firstBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

protocol TitleTextFieldDelegate: AnyObject {
    func titletextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

final class FirstMakeFolderBaseView: BaseView {
    
    let startMentLabel = UILabel()
    let imageView = UIImageView(frame: .zero)
    let titleTextField = UITextField()
    let textCountLabel = UILabel()
    
    weak var titleTextFieldDelegate: TitleTextFieldDelegate?
    
    override func configureHierarchy() {
        addSubview(startMentLabel)
        addSubview(imageView)
        addSubview(titleTextField)
        addSubview(textCountLabel)
    }
    override func configureLayout() {
        
        startMentLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.top).inset(12)
            make.horizontalEdges.equalTo(120)
        }
        titleTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(100)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        textCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(titleTextField)
            make.bottom.equalTo(titleTextField.snp.top).inset(4)
        }
    }
    override func designView() {
        textCountLabel.textAlignment = .right
        imageView.image = UIImage(named: "defaultFolderImage")
        
    }
    override func register() {
        titleTextField.delegate = self
    }
    func folderImageSetting(size: CGFloat){
        imageView.snp.makeConstraints { make in
            make.size.equalTo(size * 0.6)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide).offset(150)
        }
    }
}

extension FirstMakeFolderBaseView: UISearchTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        titleTextFieldDelegate?.titletextField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? false
    }
}
