//
//  MemoSimpleCollectionViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
import SnapKit

final class MemoSimpleCollectionViewCell: BaseCollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let dateLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(dateLabel)
    }
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(14)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(4)
            
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
    }
    override func designView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16,weight: .bold)
        
        subTitleLabel.font = .systemFont(ofSize: 12, weight: .light)
        
        dateLabel.font = .systemFont(ofSize: 14, weight: .ultraLight)
    }
    
}
