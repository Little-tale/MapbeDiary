//
//  BaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#function)
        all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func all(){
        configureHierarchy()
        configureLayout()
        designView()
        register()
        subscribe()
    }
    
    func configureHierarchy(){
        
    }
    func configureLayout(){
        
    }
    func designView(){
        
    }
    func register(){
        
    }
    func subscribe(){
        
    }
    
}
