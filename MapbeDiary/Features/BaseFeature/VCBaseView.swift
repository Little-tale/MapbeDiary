//
//  VCBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/11/26.
//

import UIKit

class VCBaseView: UIView, BaseUIProtocol {

    required convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        setupUI()
        register()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHierarchy() {}
    
    func setupConstraints() {}
    
    func setupUI() {}
    
    func register() {}
}
