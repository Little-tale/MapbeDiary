//
//  CalendarCollectionViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import UIKit
import SnapKit
import Kingfisher

class CalendarCollectionViewCell: BaseCollectionViewCell {
    let imageView = UIImageView(frame: .zero)
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    let sideButton = UIButton(frame: .zero)
    
    let viewModel = CalendarCellViewModel()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sideButton)
        contentView.addSubview(dateLabel)
    }

    
    func subscribe(_ location: LocationMemo){
        let input = CalendarCellViewModel.Input(locationMemo: location)
        let output = viewModel.trasform(input)
        
        titleLabel.text = output.titleLabel
        dateLabel.text = output.dateLabel
        
        if let imageData = output.imageData {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageData, options: [.processor(ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100)))])
        }
    }
    
    
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(imageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(10)
            make.trailing.equalTo(sideButton.snp.leading).inset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(4)
        }
        
        sideButton.snp.makeConstraints { make in
            make.trailing.verticalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(40)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.trailing.equalTo(titleLabel)
            make.height.equalTo(14)
        }
    }

    
    override func designView() {
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .right
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        dateLabel.font = .systemFont(ofSize: 14, weight: .thin)
    }
}


