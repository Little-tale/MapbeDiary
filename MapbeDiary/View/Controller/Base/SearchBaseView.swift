//
//  SearchBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchBaseView: BaseView {
    let backButton = UIButton(frame: .zero)
    let searchBar = UISearchBar()
    let emptyImage = SearchBaseImageView()
    
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: createLayout())
    
        
    override func configureHierarchy() {
        addSubview(backButton)
        addSubview(searchBar)
        addSubview(collectionView)
        addSubview(emptyImage)
        
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(34)
            make.height.equalTo(40)
        }
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar)
            make.trailing.equalTo(searchBar.snp.leading).inset( 4 )
            make.size.equalTo(28)
        }
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(searchBar.snp.bottom).offset(4)
        }
        emptyImage.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(140)
        }
    }
    
    override func register() {
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.reusebleIdentifier)
    }
    override func designView() {
        searchBar.setTextFieldBackground(color: .white, transparentBackground: true)
        searchBar.placeholder = MapTextSection.emptySearcBarText
    
        backButton.setBackgroundImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        backButton.clipsToBounds = true
        backButton.tintColor = .wheetSideBrown
       
    }
}


extension SearchBaseView {
    func createLayout() -> UICollectionViewLayout {
        var configu = UICollectionLayoutListConfiguration(appearance: .plain)
        configu.showsSeparators = true
        configu.backgroundColor = .wheetLightBrown
        let layout = UICollectionViewCompositionalLayout.list(using: configu)
        
        return layout
    }
}
