//
//  MemosHomeBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
import SnapKit

class MemosHomeBaseView: BaseView {
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    var allMemoViewModel = AllMemoListViewModel()
    
    
    override func configureHierarchy() {
        addSubview(collectionView)
    }
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}

extension MemosHomeBaseView {
    func createLayout() -> UICollectionViewLayout{
        var configu = UICollectionLayoutListConfiguration(appearance: .plain)
        configu.showsSeparators = true
        
        let layout = UICollectionViewCompositionalLayout.list(using: configu)
        
        return layout
    }
    
}
