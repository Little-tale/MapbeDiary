//
//  SearchEmptyView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchEmptyView: BaseView {
    
    private let imageView = UIImageView(frame: .zero)
    
    private let emptyLabel = UILabel().after {
        $0.text = MapTextSection.searchEmptyText
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .wheetDarkBrown
    }
    
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
}
