//
//  BaseHomeViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit

class BaseHomeViewController<T:BaseView>: UIViewController {
    
    let homeView = T()
    
    override func loadView() {
        view = homeView
        homeView.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}
