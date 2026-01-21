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
    
    private let stackView = UIStackView().after {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 4
    }

    private let memoContainerView = UIView()

    private let topRowStackView = UIStackView().after {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 8
    }

    private let phoneRowStackView = UIStackView().after {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 4
    }

    private let topRowSpacerView = UIView()
    
    let modifyLocationButton = ImageWithTextButtonView().after {
        $0.textLabel.text = "Modify_title".localized
        $0.textLabel.font = JHFont.UIKit.re17
        $0.textLabel.textColor = .white
        $0.imageView.image = UIImage(systemName: "pencil")
        $0.imageView.tintColor = .white
        $0.backgroundColor = .black
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let phoneNumberImageView = UIImageView().after {
        $0.image = .phone
        $0.tintColor = .green
    }
    
    let phoneNumberLabel = UILabel().after {
        $0.textAlignment = .right
        $0.font = JHFont.UIKit.me17
    }
    
    override func configureHierarchy() {
        addSubview(locationTitleLabel)
        addSubview(stackView)
        
        stackView.addArrangedSubview(memoContainerView)
        stackView.addArrangedSubview(topRowStackView)
        stackView.addArrangedSubview(regDateLabel)
        
        memoContainerView.addSubview(locationMemoLabel)
        topRowStackView.addArrangedSubview(phoneRowStackView)
        topRowStackView.addArrangedSubview(topRowSpacerView)
        topRowStackView.addArrangedSubview(modifyLocationButton)
        phoneRowStackView.addArrangedSubview(phoneNumberImageView)
        phoneRowStackView.addArrangedSubview(phoneNumberLabel)
    }
    
    override func configureLayout() {
        locationTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(locationTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }

        locationMemoLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        phoneNumberImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
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
        let memoContents = data.contents?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.locationMemoLabel.text = memoContents
        updateMemoRow(isHidden: memoContents?.isEmpty ?? true)
        self.regDateLabel.text = DateFormatterManager.shared.localDate(
            data.regDate,
            style: .medium,
            timeStyle: .short
        )
        let phoneNumber = data.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phoneNumberLabel.text = phoneNumber
        updatePhoneRow(isHidden: phoneNumber?.isEmpty ?? true)
    }
}

private extension MemoDetailView {
    private func updateMemoRow(isHidden: Bool) {
        let isArranged = stackView.arrangedSubviews.contains(memoContainerView)
        if isHidden {
            if isArranged {
                stackView.removeArrangedSubview(memoContainerView)
                memoContainerView.removeFromSuperview()
            }
        } else if !isArranged {
            stackView.insertArrangedSubview(memoContainerView, at: 0)
        }
    }

    private func updatePhoneRow(isHidden: Bool) {
        let isArranged = topRowStackView.arrangedSubviews.contains(phoneRowStackView)
        if isHidden {
            if isArranged {
                topRowStackView.removeArrangedSubview(phoneRowStackView)
                phoneRowStackView.removeFromSuperview()
            }
        } else if !isArranged {
            topRowStackView.insertArrangedSubview(phoneRowStackView, at: 0)
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    let view = MemoDetailView()
    view.setData(data: LocationMemoEntity(
        id: "1",
        title: "서울 중구 을지로 1가의 맛집",
        location: nil,
        contents: nil, // "미슐랭 2스타 맛집임",
        phoneNumber: "010-0000-0001",
        regDate: Date(),
        detailMemos: [])
    )
    return view
}
#endif
