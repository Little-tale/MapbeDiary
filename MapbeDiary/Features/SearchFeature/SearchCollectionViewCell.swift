//
//  SearchTableCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: BaseCollectionViewCell {
    
    private let stackView = UIStackView().after {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .equalSpacing
        $0.alignment = .leading
    }
    
    let placeNameLabel = UILabel(frame: .zero).after {
        $0.font = JHFont.UIKit.bo17
    }
    
    let roadNameLabel = UILabel(frame: .zero).after {
        $0.font = JHFont.UIKit.re14
    }
    
    private let trailingArrow = UIImageView().after {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .lightGray.withAlphaComponent(0.4)
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(placeNameLabel)
        stackView.addArrangedSubview(roadNameLabel)
        contentView.addSubview(trailingArrow)
    }
    
    override func configureLayout() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(trailingArrow.snp.leading)
            make.bottom.equalToSuperview().inset(12)
        }
        trailingArrow.snp.makeConstraints { make in
            make.top.equalTo(stackView)
            make.trailing.equalToSuperview().inset(12)
        }
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        clearText()
        layoutIfNeeded()
    }
    
    private func clearText(){
        placeNameLabel.textColor = .black
        roadNameLabel.textColor = .black
    }
}


