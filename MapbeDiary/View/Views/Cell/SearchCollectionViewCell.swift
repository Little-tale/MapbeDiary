//
//  SearchTableCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: BaseCollectionViewCell {
    let placeNameLabel = UILabel(frame: .zero)
    let roadNameLabel = UILabel(frame: .zero)
    
    
    override func configureHierarchy() {
        contentView.addSubview(placeNameLabel)
        contentView.addSubview(roadNameLabel)
    }
    override func configureLayout() {
        placeNameLabel.snp.makeConstraints{ make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
        }
        roadNameLabel.snp.makeConstraints{ make in
            make.horizontalEdges.equalTo(placeNameLabel)
            make.top.equalTo(placeNameLabel.snp.bottom).offset(10)
            make.height.equalTo(placeNameLabel)
            make.bottom.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        roadNameLabel.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(10)
        }
    }
    override func designView() {
        placeNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        roadNameLabel.font = .systemFont(ofSize: 15, weight: .light)
    }
}


