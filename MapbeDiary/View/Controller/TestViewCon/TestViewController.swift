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
    
    let testSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        t.backgroundColor = .darkGray
        backView.backgroundColor = .brown
        view.addSubview(backView)
        backView.addSubview(t)
        backView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        
        t.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(110)
        }
        view.addSubview(testSearchBar)
        testSearchBar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(12)
            make.top.equalTo(t.snp.bottom).offset(8)
            make.height.equalTo(40)
        }
        testNavi()
        backView.layer.cornerRadius = 24
        
    }
    
    func testNavi(){
        navigationItem.title = "새로운 장소"
        
        let rightItem = UIBarButtonItem(title: "저장",image: nil, target: self , action: #selector(test))
        navigationItem.rightBarButtonItem = rightItem
        
        testSearchBar.delegate = self
        testSearchBar.backgroundImage = UIImage()
        testSearchBar.setTextFieldBackground(color: UIColor.white, transparentBackground: true)
        testSearchBar.placeholder = "검색하세요~"

    }
    
    @objc
    func test(_ sender: UIButton) {
        print(sender)
    }
}
// let regex4 = "[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]"
extension TestViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = String.testString(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let search = searchBar.text
        let results = search?.trimmingCharacters(in: .whitespaces)
        searchBar.text = results
    }
    
}





// #"^\(?\d{3}\)?[ -]?\d{3,4}[ -]?\d{4}$"#
