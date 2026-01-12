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
            backgroundColor: .wheetLightBrown,
            layout: .insetGrouped
        )
    )
    
    override func setupHierarchy() {
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    override func setupUI() {
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
    }
}

extension SettingVCView {
    
}
