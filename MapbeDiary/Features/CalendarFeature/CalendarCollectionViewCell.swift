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
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    let viewModel = CalendarCellViewModel()
    
    override func configureHierarchy() {
        RealmRepository().printURL()
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        contentView.addSubview(dateLabel)
    }

    
    func subscribe(_ location: LocationMemo){
        let input = CalendarCellViewModel.Input(locationMemo: location)
        let output = viewModel.trasform(input)
        
        titleLabel.text = output.titleLabel
        titleLabel.textAlignment = .left
        dateLabel.text = output.dateLabel
        
        if let imageData = output.imageData {
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.top).offset(10)
                make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
                make.leading.equalTo(imageView.snp.trailing).offset(12)
            }
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageData,
                options: [.processor(ResizingImageProcessor(
                    referenceSize: CGSize(width: 150, height: 150)
                ))]
            )
        } else {
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
                make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
                make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(12)
            }
        }
    }
    
    
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(imageView.snp.height)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(14)
        }
    }

    
    override func designView() {
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        dateLabel.font = .systemFont(ofSize: 14, weight: .thin)
    }
}


//    let sideButton = UIButton(frame: .zero)
    //        contentView.addSubview(sideButton)
//        sideButton.snp.makeConstraints { make in
//            make.trailing.verticalEdges.equalTo(contentView.safeAreaLayoutGuide)
//            make.width.equalTo(40)
//        }

