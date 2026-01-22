//
//  SettingVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit
import SnapKit

final class SettingVCView: VCBaseView {
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CollectionViewLayouts.makeListLayout(
            backgroundColor: .md(.whiteLightBackground),
            layout: .insetGrouped
        )
    )
    
    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName:"chevron.backward")
        config.baseForegroundColor = .black
        $0.configuration = config
    }
    
    let topTitleLabel = UILabel().after {
        $0.text = "설정"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    override func setupHierarchy() {
        addSubview(backButton)
        addSubview(topTitleLabel)
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalTo(topTitleLabel)
            make.size.equalTo(40)
        }
        
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(45)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func setupUI() {
        self.backgroundColor = .white
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
    }
}

extension SettingVCView {
    
}
