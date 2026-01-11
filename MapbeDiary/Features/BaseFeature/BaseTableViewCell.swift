//
//  BaseTableViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        all()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func all(){
        configureHierarchy()
        configureLayout()
        designView()
        registers()
    }
    
    func configureHierarchy(){
        
    }
    func configureLayout(){
        
    }
    func designView(){
        
    }
    func registers(){
        
    }
    
}
