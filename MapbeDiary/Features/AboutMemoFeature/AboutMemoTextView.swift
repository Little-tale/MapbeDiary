//
//  AboutMemoTextView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/17/26.
//

import UIKit
import SnapKit

final class AboutMemoTextView: BaseView {
    
    let textView = UITextView()
    
    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            setPlaceHolder(isOn: newValue.isEmpty)
            enforceTextLimitIfNeeded()
            updateCountLabel()
        }
    }
    
    var textFont: UIFont? {
        get { textView.font }
        set { textView.font = newValue }
    }
    
    var maxCount: Int? {
        didSet {
            enforceTextLimitIfNeeded()
            updateCountLabel()
        }
    }
    
    private let placeHolderLabel = UILabel()
    private let countLabel = UILabel()

    
    override func configureHierarchy() {
        addSubview(textView)
        addSubview(placeHolderLabel)
        addSubview(countLabel)
    }
    
    override func configureLayout() {
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeHolderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(14)
        }
        
        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(6)
        }
    }
    
    override func designView() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 10
        clipsToBounds = true
        
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        textView.contentInset = .zero
        textView.delegate = self
        
        placeHolderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.098, alpha: 0.22)
        placeHolderLabel.numberOfLines = 0
        
        countLabel.font = .systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = .secondaryLabel
    }
}

extension AboutMemoTextView {
    
    func setPlaceHolderText(_ text: String) {
        placeHolderLabel.text = text
    }
    
    private func setPlaceHolder(isOn: Bool) {
        placeHolderLabel.isHidden = !isOn
    }
    
    private func updateCountLabel() {
        let count = textView.text?.count ?? 0
        if let maxCount {
            countLabel.text = "\(count)/\(maxCount)"
        } else {
            countLabel.text = "\(count)"
        }
        bringSubviewToFront(countLabel)
    }
    
    private func enforceTextLimitIfNeeded() {
        guard let maxCount, let currentText = textView.text, currentText.count > maxCount else {
            return
        }
        
        let endIndex = currentText.index(currentText.startIndex, offsetBy: maxCount)
        textView.text = String(currentText[..<endIndex])
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
    }
}

extension AboutMemoTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        enforceTextLimitIfNeeded()
        updateCountLabel()
        setPlaceHolder(isOn: textView.text.isEmpty)
    }
}
