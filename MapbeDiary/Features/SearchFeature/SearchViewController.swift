//
//  SearchViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: ReactorBaseViewController<SearchReactor, SearchVCView> {
    
    enum Section: CaseIterable {
        case search
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,PlaceDocumentEntity>?
    
    var kakaoDataClosure: ((PlaceDocumentEntity) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSetting()
        collectionViewDataSource()
    }
    
    override func bind(reactor: SearchReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .map { $0.searchResults }
            .distinctUntilChanged()
            .bind(with: self) { owner, items in
                owner.applySnapshot(items: items)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorModel }
            .compactMap { $0 }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(urlError: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, bool in
                owner.mainView.emptyView.isHidden = !bool
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: SearchReactor) {
        let searchBarEvent = Observable.merge(
            mainView.searchBar.rx.textDidEndEditing.asObservable(),
            mainView.searchBar.rx.searchButtonClicked.asObservable()
        )
        
        searchBarEvent
            .withUnretained(self)
            .filter { owner, _ in
                owner.view.endEditing(true)
                return true
            }
            .withLatestFrom(mainView.searchBar.rx.text)
            .distinctUntilChanged()
            .map { text in SearchReactor.Action.search(currentText: text) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .itemSelected
            .throttle(.milliseconds(300), latest: false ,scheduler: MainScheduler.instance)
            .map { $0.item }
            .withUnretained(self)
            .compactMap { owner, item in
                owner.reactor?.currentState.searchResults[item]
            }
            .bind(with: self) { owner, model in
                owner.kakaoDataClosure?(model)
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .willDisplayCell
            .map { $0.at }
            .withUnretained(self)
            .filter { owner, index in
                let threshold = 5
                let count = owner.reactor?.currentState.searchResults.count ?? 0
                return index.item > (count - threshold)
            }
            .map { _ in SearchReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewDidAppear
            .bind(with: self) { owner, _ in
                owner.mainView.searchBar.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
        
        mainView.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController {
    
    private func setUpSetting() {
        mainView.backgroundColor = .white
        mainView.collectionView.backgroundColor = .white
    }

}

// MARK: CollectionView Setting
extension SearchViewController {
    
    private func applySnapshot(items: [PlaceDocumentEntity], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,PlaceDocumentEntity>()
        snapshot.appendSections([.search])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot, animatingDifferences: animated)
    }
    
    private func collectionViewDataSource(){
        let cellRegister = makeCollectionViewRegister()
        
        dataSource = UICollectionViewDiffableDataSource<Section,PlaceDocumentEntity>(
            collectionView: mainView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegister,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    private func makeCollectionViewRegister() -> UICollectionView.CellRegistration<SearchCollectionViewCell,PlaceDocumentEntity> {
        let cellRegister = UICollectionView
            .CellRegistration<SearchCollectionViewCell,PlaceDocumentEntity> { [weak self] cell, indexPath, item in
            guard let self else { return }

            cell.placeNameLabel.text = item.placeName
                
            cell.placeNameLabel.asFont(
                targetString: reactor?.currentState.currentText ?? ""
            )
            
            cell.roadNameLabel.text = item.roadAddressName
            
            cell.roadNameLabel.asFont(
                targetString: reactor?.currentState.currentText ?? ""
            )
                
            cell.backgroundColor = .white
        }
        return cellRegister
    }
}
