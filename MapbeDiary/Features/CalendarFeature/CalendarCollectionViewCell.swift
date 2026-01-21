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
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let emptyView = AllLocationCellEmptyView().after {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let stackView = UIStackView().after {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 8
        $0.alignment = .leading
    }
    
    private let titleLabel = UILabel().after {
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    private let subtitleLabel: UILabel = UILabel().after {
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .lightGray
    }
    
    private let dateLabel = UILabel().after {
        $0.font = .systemFont(ofSize: 14, weight: .thin)
        $0.textColor = .lightGray
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(emptyView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(8)
            make.width.equalTo(imageView.snp.height)
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(14)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(14)
            make.leading.equalTo(stackView.snp.leading)
        }
    }
    
}

extension CalendarCollectionViewCell {
    
    func setModel(location: LocationMemoEntity) {
        let title = location.title
        
        let dateString = DateFormatterManager.shared.localDate(
            location.regDate,
            style: .short,
            timeStyle: .short
        )
        
        let url = FileManagers.shard.loadImageOrignerMarker(location.id)
        
        titleLabel.text = title
        subtitleLabel.text = location.contents ?? "Memo_empty".localized
        if location.contents?.isEmpty == true { subtitleLabel.text = "Memo_empty".localized }
        dateLabel.text = dateString
        
        
        if let imageUrl = url {
            emptyView.isHidden = true
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageUrl,
                options: [.processor(ResizingImageProcessor(
                    referenceSize: CGSize(width: 150, height: 150)
                ))]
            )
        } else {
            emptyView.isHidden = false
        }
        
        setNeedsLayout()
    }
}
