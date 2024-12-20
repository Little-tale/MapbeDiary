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
    
    var kakaoDataClosure: ((Document) -> Void )?
    
    private var debounceItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewCollerSetting()
        subscribe()
        searchBarSetup()
        homeView.collectionView.delegate = self
        
        collectionViewSettup()
        
        collectionViewDataSource() //
        
        snapShot() // 그릇이 있어야 해서 뒤에
        
        homeView.backButton.addTarget(self, action: #selector(onlyDismiss), for: .touchUpInside)
        
    }
    private func viewCollerSetting(){
        homeView.backgroundColor = .white
        homeView.collectionView.backgroundColor = .white
    }
    
    private func collectionViewDataSource(){
        let cellregister = UICollectionView.CellRegistration<SearchCollectionViewCell,Document> {
            [weak self]
            cell, indexPath, item in
            guard let self else { return }
            // 스크린샷 용 더미
         
            
            cell.placeNameLabel.text = item.placeName
            cell.placeNameLabel.asFont(targetString: searchViewModel.searchTextOb.value?.searchText ?? "")
            
            cell.roadNameLabel.text = item.roadAddressName
            cell.roadNameLabel.asFont(targetString: searchViewModel.searchTextOb.value?.searchText ?? "")
            cell.backgroundColor = .white
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
    
    deinit {
        print("사라질께요!", self)
    }
}

// MARK: 컬렉션뷰셀 클릭시 수행 동작
extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard searchViewModel.outPutModel.value != nil else { return }
        // let data = datas[indexPath.item]
        let realData = dataSource?.itemIdentifier(for: indexPath)
        guard let realData else { return }
        
        kakaoDataClosure?(realData)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        collectionViewCellAnimation(cell: cell)
        
        onlyDismiss()
    }
}
// MARK: 페이지 네이션
extension SearchViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard let index =  indexPaths.map({ $0.row }).max() else {return}
        guard let end = searchViewModel.endPageBool else {return}
        guard searchViewModel.currentPage.value != nil else {return}
        print(searchViewModel.pageNation)
        
        if searchViewModel.pageNation - 2 < index,
           !end {
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
    
    private func snapShot(){
        if let kakaoData = searchViewModel.outPutModel.value {
            var snapshot = NSDiffableDataSourceSnapshot<Section,Document>()
            snapshot.appendSections([.search]) //
            snapshot.appendItems(kakaoData)
            dataSource?.apply(snapshot, animatingDifferences: true) 
        }
    }
    
}
// MARK: 서치바 서치 할시
extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isUserInteractionEnabled = false
        searchViewModel.outPutModel.value = []
        searchViewModel.currentPage.value = 1
        searchViewModel.pageNation = 15
        searchViewModel.searchTextOb.value?.searchText = searchBar.text ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            searchBar.isUserInteractionEnabled = true
        }
        view.endEditing(true)
    }
}

extension SearchViewController {
    func subscribe(){
        searchViewModel
            .outPutModel
            .guardBind(object: self) { owner, model in
                guard let model else { return }
                owner.checkResult(model.count)
            }
        searchViewModel
            .outPutError
            .guardBind(object: self) { owner, error in
                guard let error else { return }
                owner.showAPIErrorAlert(urlError: error)
            }
    }
}

extension SearchViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeView.searchBar.becomeFirstResponder()
    }
    
    private func checkResult(_ connt: Int) {
        debounceItem?.cancel()
        let work = DispatchWorkItem {
            [weak self] in
            self?.snapShot()
            if  connt == 0 {
                self?.homeView.emptyImage.isHidden = false
            }else {
                self?.homeView.emptyImage.isHidden = true
            }
        }
        debounceItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
    }
}

extension SearchViewController {
    @objc
    private func onlyDismiss(){
        dismiss(animated: false)
    }
}
