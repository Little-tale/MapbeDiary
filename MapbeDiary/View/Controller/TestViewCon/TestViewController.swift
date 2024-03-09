//
//  TestViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import SnapKit

class TestViewController: UIViewController{
    private let backView = UIView()
    let t = AddTitleDateImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        view.addSubview(backView)
        backView.addSubview(t)
        backView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        backView.backgroundColor = .white
        
        t.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(110)
        }
        testNavi()
        backView.layer.cornerRadius = 24
        
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
}


