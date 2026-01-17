//
//  BaseUITextView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/17/26.
//

import UIKit

class BaseUITextView: UITextView, BaseUIProtocol {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHierarchy() {}
    
    func setupConstraints() {}
    
    func setupUI() {}
    
}
