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
        
        imageView.kf.indicatorType = .activity
        
        imageView.kf.setImage(with: output.imageData, options: [.processor(ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100)))])
    }
    
    
    override func configureLayout() {
        
        imageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(10)
            make.height.equalTo(16)
            make.trailing.equalTo(sideButton.snp.leading).inset(4)
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
}


