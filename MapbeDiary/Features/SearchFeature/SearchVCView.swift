//
//  SearchVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit
import SnapKit
import SwiftImageCompressor

final class SearchVCView: VCBaseView {
    
    // MARK: Property
    let backButton = UIButton(frame: .zero)
    
    let searchBar = UISearchBar()
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CollectionViewLayouts.makeListLayout()
    )
    
    let emptyView = SearchEmptyView()
    
    
    override func setupHierarchy() {
        addSubview(backButton)
        addSubview(searchBar)
        addSubview(collectionView)
        addSubview(emptyView)
    }
    
    override func setupConstraints() {
        
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
        
        emptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        setSearchBar() // 서치바 세팅
        setBackButton() // 백버튼 세팅
    }
    
}

// MARK: Set UI
extension SearchVCView {
    
    /// searchBar Setup UI
    private func setSearchBar() {
        
        searchBar.setTextFieldBackground(
            color: .white,
            transparentBackground: true
        )
        
        searchBar.placeholder = MapTextSection.emptySearchBarText
    }
    
    /// BackButton Setup UI
    private func setBackButton() {
        let backImage = UIImage(systemName: "chevron.left")
        
        guard var backImage else { return }
        
        backImage.withRenderingMode(.alwaysTemplate)
        
        backImage = backImage.resizeImage(maxDimension: 16)
        
        backButton.setImage(backImage, for: .normal)
        backButton.clipsToBounds = true
        backButton.tintColor = .black
    }
}
