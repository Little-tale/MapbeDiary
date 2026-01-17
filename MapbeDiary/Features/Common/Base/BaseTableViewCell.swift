//
//  BaseTableViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell, BaseUIProtocol {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        setupUI()
        register()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupUI() {
        
    }
    
    func register() {
        
    }
}
