//
//  BaseCollectionReusableView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import UIKit

class BaseCollectionReusableView: UICollectionReusableView, BaseUIProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
