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
    
    private let imageView: UIImageView = UIImageView().after {
        $0.contentMode = .scaleAspectFill
    }
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private var titleLeadingToImage: Constraint?
    private var titleLeadingToContent: Constraint?
    private var imageWidthToHeight: Constraint?
    private var imageWidthZero: Constraint?
    
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }
    
    func setModel(location: LocationMemoEntity) {
        let title = location.title
        
        let dateString = DateFormatterManager.shared.localDate(
            location.regDate,
            style: .short,
            timeStyle: .short
        )
        
        let url = FileManagers.shard.loadImageOrignerMarker(location.id)
        
        titleLabel.text = title
        dateLabel.text = dateString
        
        
        if let imageUrl = url {
            imageView.isHidden = false
            imageWidthZero?.deactivate()
            imageWidthToHeight?.activate()
            titleLeadingToContent?.deactivate()
            titleLeadingToImage?.activate()
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageUrl,
                options: [.processor(ResizingImageProcessor(
                    referenceSize: CGSize(width: 150, height: 150)
                ))]
            )
        } else {
            imageView.isHidden = true
            imageWidthToHeight?.deactivate()
            imageWidthZero?.activate()
            titleLeadingToImage?.deactivate()
            titleLeadingToContent?.activate()
        }
        
        setNeedsLayout()
    }
    
    
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(contentView.safeAreaLayoutGuide)
            imageWidthToHeight = make.width.equalTo(imageView.snp.height).constraint
            imageWidthZero = make.width.equalTo(0).constraint
        }
        imageWidthZero?.deactivate()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            titleLeadingToImage = make.leading.equalTo(imageView.snp.trailing).offset(12).constraint
            titleLeadingToContent = make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(12).constraint
            make.bottom.lessThanOrEqualTo(dateLabel.snp.top).offset(-6)
        }
        titleLeadingToContent?.deactivate()
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.leading.equalTo(titleLabel.snp.leading)
            make.height.equalTo(14)
        }
    }

    
    override func designView() {
        imageView.clipsToBounds = true
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        dateLabel.font = .systemFont(ofSize: 14, weight: .thin)
    }
    
    
}
