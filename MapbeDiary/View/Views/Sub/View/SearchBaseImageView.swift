//
//  SearchBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchBaseImageView: BaseView{
    private let imageView = UIImageView(frame: .zero)
    private let emptyLabel: UILabel = {
        let view = UILabel()
        view.text = "검색하실 장소를\n입력해주세요!"
        view.textAlignment = .center
        view.numberOfLines = 2
        view.textColor = .green
        return view
    }()
    
    override func configureHierarchy() {
        addSubview(imageView)
        addSubview(emptyLabel)
    }
    override func configureLayout() {
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(100)
        }
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(imageView)
            make.height.equalTo(50)
        }
    }
    override func designView() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "SeachImage")
    }
    
    deinit {
        print("사라져 드립니다.",self)
    }
}
