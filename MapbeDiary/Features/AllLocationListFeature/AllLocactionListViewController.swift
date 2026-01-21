//
//  AllMemoListViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
import RxSwift
import RxCocoa

protocol AllMemoLocationListViewControllerDelegate: AnyObject {

    func modifyRequest(memoLocation: LocationMemoEntity)
    
    func showMarker(memoLocation: LocationMemoEntity)
}

final class AllMemoLocationListViewController: ReactorBaseViewController<AllLocationListViewReactor, AllLocationVCView> {
    
    weak var delegate: AllMemoLocationListViewControllerDelegate?
    
    var dataSource: UICollectionViewDiffableDataSource<FolderEntity,LocationMemoEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDataSource()
        snapShot()
    }
    
    
    override func bind(reactor: AllLocationListViewReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .map { $0.dismissTrigger }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.showDeleteAlert }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.deleteAlert()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.item }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, model in
                owner.snapShot()
                owner.mainView.topTitleLabel.text = model.name
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.realmError }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.modifyTrigger }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, location in
                owner.delegate?.modifyRequest(memoLocation: location)
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: AllLocationListViewReactor) {
        rx.viewWillAppear
            .map { _ in AllLocationListViewReactor.Action.reload }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewDidLoad
            .map{ _ in AllLocationListViewReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                owner.dataSource?.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, entity in
                owner.delegate?.showMarker(memoLocation: entity)
            }
            .disposed(by: disposeBag)
        
        mainView.swipeAction = { [weak self] action, indexPath in
            self?.reactor?.action.onNext(.swipeAction(action: action, index: indexPath.item))
        }
    }
}

// MARK: Alert
extension AllMemoLocationListViewController {
    
    private func deleteAlert(){
        showAlert(
            title: "Alert_delete".localized,
            message: "Alert_cantRecover".localized,
            actionTitle: "Did_delete".localized
        ) { [weak self] action in
            guard let self else {return}
            reactor?.action.onNext(.checkedDelete)
        }
    }
}


// MARK: 데이터 소스
extension AllMemoLocationListViewController {
    private func collectionViewDataSource(){
        let cellRegister = UICollectionView.CellRegistration<MemoSimpleCollectionViewCell,LocationMemoEntity>{
            [weak self] cell, indexPath, item in
            guard self != nil else { return }
            
            var image: UIImage? = nil
            let imageUrl = FileManagers.shard.loadImageOrignerMarker(memoId: item.id)
            
            if let imageUrl {
                image = UIImage(contentsOfFile: imageUrl)
            }
            
            cell.setConfiguration(
                MemoSimpleCollectionViewCell.Configuration(
                    title: item.title,
                    subTitle: item.contents,
                    date: DateFormatterManager.shared.localDate(item.regDate),
                    image: image
                )
            )
        }
        
        dataSource = UICollectionViewDiffableDataSource<FolderEntity,LocationMemoEntity>(
            collectionView: mainView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: itemIdentifier)
        })
    }
}

extension AllMemoLocationListViewController {
    //MARK: SnapShot
    private func snapShot(){
        guard let data = reactor?.currentState.item else {
            return
        }
        
        var snapShot = NSDiffableDataSourceSnapshot<FolderEntity, LocationMemoEntity>()
        
        snapShot.appendSections([data])
        snapShot.appendItems(data.locationMemos, toSection: data)
        
        dataSource?.apply(snapShot)
        // applySnapshotUsingReloadData
    }
}
