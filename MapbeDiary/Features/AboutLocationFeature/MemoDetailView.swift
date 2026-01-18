//
//  MemoDetailView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import UIKit
import SnapKit

final class MemoDetailView: BaseView {
    
    let locationTitleLabel = UILabel().after {
        $0.font = JHFont.UIKit.bo24
        $0.numberOfLines = 2
    }
    
    let locationMemoLabel = UILabel().after {
        $0.font = JHFont.UIKit.re17
        $0.numberOfLines = 3
    }
    
    let regDateLabel = UILabel().after {
        $0.textAlignment = .right
        $0.font = JHFont.UIKit.re14
    }
    
    let modifyLocationButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.title = "Modify_title".localized
        config.baseForegroundColor = .md(.textPrimary)
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        $0.configuration = config
    }
    
    private let phoneNumberImageView = UIImageView().after {
        $0.image = UIImage(systemName: "phone.fill")
        $0.tintColor = .md(.tagBlue)
    }
    
    let phoneNumberLabel = UILabel().after {
        $0.textAlignment = .right
        $0.font = JHFont.UIKit.me17
    }
    
    override func configureHierarchy() {
        addSubview(locationTitleLabel)
        addSubview(locationMemoLabel)
        addSubview(regDateLabel)
        addSubview(modifyLocationButton)
        addSubview(phoneNumberLabel)
        addSubview(phoneNumberImageView)
    }
    
    override func configureLayout() {
        locationTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        locationMemoLabel.snp.makeConstraints { make in
            make.top.equalTo(locationTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(locationMemoLabel)
        }
        
        phoneNumberImageView.snp.makeConstraints { make in
            make.top.equalTo(locationMemoLabel.snp.bottom).offset(8)
            make.leading.equalTo(locationMemoLabel)
            make.size.equalTo(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        phoneNumberLabel.snp.makeConstraints { make in
            make.leading.equalTo(phoneNumberImageView.snp.trailing).offset(4)
            make.centerY.equalTo(phoneNumberImageView)
        }
        
        regDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        modifyLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(regDateLabel.snp.top)
            make.trailing.equalToSuperview().inset(8)
        }
    }
}

extension MemoDetailView {
    
    func setData(data: LocationMemoEntity) {
        self.locationTitleLabel.text = data.title
        self.locationMemoLabel.text = data.contents
        self.regDateLabel.text = DateFormatterManager.shared.localDate(
            data.regDate,
            style: .medium,
            timeStyle: .short
        )
        self.phoneNumberLabel.text = data.phoneNumber
    }
}
