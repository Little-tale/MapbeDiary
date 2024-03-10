//
//  SearchViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit

enum Section: CaseIterable {
    case search
}

final class SearchViewController: BaseHomeViewController<SearchBaseView> {
    
    let searchViewModel = SearchViewModel()
    var dataSource: UICollectionViewDiffableDataSource<Section,Document>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.collectionView.delegate = self
        collectionViewSettup()
        searchBarSetup()
        subscribe()
        collectionViewDataSource()
        snapShot()
    }
    
    private func collectionViewDataSource(){
        let cellregister = UICollectionView.CellRegistration<SearchCollectionViewCell,Document> { cell, indexPath, item in
            cell.placeNameLabel.text = item.placeName
            cell.roadNameLabel.text = item.roadAddressName
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,Document>(collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellregister, for: indexPath, item: itemIdentifier)
        })
        
    }
    
    private func collectionViewSettup(){
        homeView.collectionView.prefetchDataSource = self
    }
    private func searchBarSetup(){
        homeView.searchBar.delegate = self
    }
}
extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

extension SearchViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let index =  indexPaths.map({ $0.row }).max() else {return}
    
        if searchViewModel.pageNation - 2 < index,
           searchViewModel.endPage != searchViewModel.pageNation {
            let page = searchViewModel.currentPage.value
            guard let page else {return}
            searchViewModel.currentPage.value = page + 1
            searchViewModel.pageNation += 15
        }
        print(indexPaths)
    }
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}
// MARK: Snapshot
extension SearchViewController {
    
    func snapShot(){
        if let kakaoData = searchViewModel.outPutModel.value {
            var snapshot = NSDiffableDataSourceSnapshot<Section,Document>()
            snapshot.appendSections([.search]) //
            snapshot.appendItems(kakaoData)
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.currentPage.value = 1
        searchViewModel.pageNation = 15
        searchViewModel.searchTextOb.value?.searchText = searchBar.text ?? ""
    }
}

extension SearchViewController {
    func subscribe(){
        searchViewModel.outPutModel.bind { [ weak self ] model in
            guard let self else { return }
            guard let model else { return }
            snapShot()
        }
        
        searchViewModel.outPutError.bind { [weak self] error in
            guard let self else { return }
            guard let error else { return}
            showAPIErrorAlert(urlError: error)  
        }
    }
}
