//
//  LocationAboutMemosView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

class LocationAboutMemosView: BaseView {
    let memoAboutBaseView = MemoAboutBaseView()
    let memoEmptyView = MemosEmptyView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    
    override func configureHierarchy() {
        addSubview(memoAboutBaseView)
        addSubview(collectionView)
        addSubview(memoEmptyView)
    }
    override func configureLayout() {
        memoAboutBaseView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(memoAboutBaseView.snp.bottom)
        }
        memoEmptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(memoEmptyView.snp.bottom).offset(4)
            make.height.equalTo(200)
        }
    }
}

extension LocationAboutMemosView {
    private static func createLayout() -> UICollectionViewLayout {
        var configu = UICollectionLayoutListConfiguration(appearance: .plain)
        configu.showsSeparators = true
        
        let layout = UICollectionViewCompositionalLayout.list(using: configu)

        return layout
    }
}
