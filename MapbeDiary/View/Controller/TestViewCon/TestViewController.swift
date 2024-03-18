//
//  TestViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import SnapKit

class TestViewController: UIViewController{
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        testNavi()
        
    }
    
    func testNavi(){
        navigationItem.title = "새로운 장소"
        
        let rightItem = UIBarButtonItem(title: "저장",image: nil, target: self , action: #selector(test))
        navigationItem.rightBarButtonItem = rightItem
        
    }
    
    @objc
    func test(_ sender: UIButton) {
        print(sender)
    }
    
    func createLayout(){
        
    }
}
