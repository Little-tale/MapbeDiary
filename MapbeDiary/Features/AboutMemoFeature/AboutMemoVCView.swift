//
//  AboutMemoVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/17/26.
//

import UIKit
import SnapKit


final class AboutMemoVCView: VCBaseView {
    
    // title
    private let titleLabel = UILabel().after {
        $0.text = "Memories_of_place".localized
        $0.font = JHFont.UIKit.bo24
    }
    
    // Back Button
    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.backward")
        config.baseForegroundColor = .wheetBlack
        $0.configuration = config
    }
    
    // Save Button (Primary Filled)
    let saveButton = UIButton().after {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .md(.primary)
        config.baseForegroundColor = .md(.onPrimary)
        config.title = "Add_save_button_text".localized

        config.cornerStyle = .capsule
        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 16
        )

        $0.configuration = config
    }

    // Delete Button
    let deleteButton = UIButton().after {
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = .md(.destructive)
        config.title = "Alert_delete".localized

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 12,
            bottom: 10,
            trailing: 12
        )

        // 텍스트 정렬/강조는 취향인데, destructive는 semibold가 보통 잘 먹음
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }

        $0.configuration = config
    }

    
    // TextView
    let memoTextView = AboutMemoTextView().after {
        $0.textFont = JHFont.UIKit.li20
        $0.setPlaceHolderText("Add_title_text_fileld_text".localized)
    }
    
    // Image Count Label
    let imageCountLabel = UILabel()
    
    // Add Image Button
    let addImageButton = UIButton().after {
        var config = UIButton.Configuration.tinted()
        config.title = "Add_image_title".localized
        config.baseBackgroundColor = .wheetBlue
        config.baseForegroundColor = .wheetBlack
        $0.configuration = config
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CollectionViewLayouts.makeMemoImagesLayout()
    ).after {
        $0.backgroundColor = .clear
    }

    override func setupHierarchy() {
        addSubview(backButton)
        addSubview(saveButton)
        addSubview(deleteButton)
        addSubview(titleLabel)
        addSubview(memoTextView)
        addSubview(imageCountLabel)
        addSubview(addImageButton)
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(8)
            make.centerX.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(titleLabel)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalTo(titleLabel)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(saveButton.snp.leading).inset(-4)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(200)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(130)
        }
    }
    
    override func setupUI() {
        self.backgroundColor = .md(.background)
    }
}
