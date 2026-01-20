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
    
    let locationMemoLabel = BubbleLabel().after {
        $0.font = JHFont.UIKit.re17
        $0.numberOfLines = 3
        $0.insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 4)
        $0.backgroundColor = .md(.tagBlue)
        $0.tailDirection = .topLeft
    }
    
    let regDateLabel = UILabel().after {
        $0.textAlignment = .right
        $0.font = JHFont.UIKit.re14
    }
    
    let modifyLocationButton = UIButton().after {
        var config = UIButton.Configuration.filled()
        config.title = "Modify_title".localized
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .md(.tagGreen)
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        $0.configuration = config
    }
    
    private let phoneNumberImageView = UIImageView().after {
        $0.image = UIImage(systemName: "phone.fill")
        $0.tintColor = .green
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
            make.top.equalTo(locationTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
        }
        
        phoneNumberImageView.snp.makeConstraints { make in
            make.top.equalTo(locationMemoLabel.snp.bottom).offset(8)
            make.leading.equalTo(locationMemoLabel)
            make.size.equalTo(20)
        }
        
        phoneNumberLabel.snp.makeConstraints { make in
            make.leading.equalTo(phoneNumberImageView.snp.trailing).offset(4)
            make.centerY.equalTo(phoneNumberImageView)
        }
        
        modifyLocationButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberLabel)
            make.trailing.equalToSuperview().inset(8)
        }
        
        regDateLabel.snp.makeConstraints { make in
            make.top.equalTo(modifyLocationButton.snp.bottom).offset(4)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxBubbleWidth = bounds.width - 16
        let maxTextWidth = max(0, maxBubbleWidth - locationMemoLabel.insets.left - locationMemoLabel.insets.right)
        if locationMemoLabel.preferredMaxLayoutWidth != maxTextWidth {
            locationMemoLabel.preferredMaxLayoutWidth = maxTextWidth
        }
    }
}

extension MemoDetailView {
    
    func setData(data: LocationMemoEntity) {
        self.locationTitleLabel.text = data.title
        self.locationMemoLabel.text = data.contents
        self.locationMemoLabel.isHidden = (data.contents?.isEmpty ?? true)
        self.regDateLabel.text = DateFormatterManager.shared.localDate(
            data.regDate,
            style: .medium,
            timeStyle: .short
        )
        self.phoneNumberLabel.text = data.phoneNumber
    }
}
