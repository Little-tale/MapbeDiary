//
//  SettingHomeView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import SnapKit

final class SettingHomeView: BaseView {
    
    let settingViewModel = SettingViewModel()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: setCollectionViewLayout())
    
    override func configureHierarchy() {
        addSubview(collectionView)
    }
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func designView() {
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
    }
    deinit {
        print("deinit: SettingHomeView")
    }
}


extension SettingHomeView {
    private func setCollectionViewLayout() -> UICollectionViewLayout {
        var layoutCoinfugu = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        layoutCoinfugu.showsSeparators = true
        layoutCoinfugu.backgroundColor = .wheetLightBrown
        
        let layout = UICollectionViewCompositionalLayout.list(using: layoutCoinfugu)
        
        return layout
    }
}
