//
//  CustomTextview.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
//MARK: 컬러 바꾸ㅓ야해
final class MemoTextview: UITextView {
    
    let memoTextViewModel = MemoTextViewModel()
    
    private enum Const {
        static let backgroundColor = UIColor.systemGray5
        static let cornerRadius = 10.0
        static let containerInset = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        static let placeholderColor = UIColor(red: 0, green: 0, blue: 0.098, alpha: 0.22)
    }
    
    private let placeHolderView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.textColor = Const.placeholderColor
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        return view
    }()
    
    init(){
        super.init(frame: .zero, textContainer: nil)
        self.delegate = self
        subsribe()
        addSubview(placeHolderView)
        setUpUi()
    }
    
    private func setUpUi(){
        backgroundColor = Const.backgroundColor
        layer.cornerRadius = Const.cornerRadius
        clipsToBounds = true
        textContainerInset = Const.containerInset
        contentInset = .zero
        
        placeHolderView.textContainer.exclusionPaths = textContainer.exclusionPaths
        placeHolderView.textContainer .lineFragmentPadding = textContainer.lineFragmentPadding
        placeHolderView.frame = bounds
    }
    private func placeHolderOnOff(bool: Bool){
        guard let placeHolderText = memoTextViewModel.placeHolderText.value else { return }
        placeHolderView.isHidden = bool
        accessibilityValue = bool ? placeHolderText : ""
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemoTextview {
    private func subsribe(){
        memoTextViewModel.placeHolderBoolOutput.bind { [weak self ] bool  in
            guard let self else { return }
            guard let bool else { return }
            placeHolderOnOff(bool: bool)
        }
    }
}


extension MemoTextview: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let model = TextViewModel(text:  textView.text, rangeStart: range.location, rangeLength: range.length, replacing: text)
        memoTextViewModel.textInput.value = model
        
        return memoTextViewModel.activeOutPut.value
    }
    
    func textViewDidChange(_ textView: UITextView) {
        memoTextViewModel.textViewdidChangeInput.value = textView.text
        if let memo = memoTextViewModel.processingText.value {
            textView.text = memo
        }
    
    }
}
