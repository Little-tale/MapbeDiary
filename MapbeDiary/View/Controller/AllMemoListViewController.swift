//
//  AllMemoListViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit

class AllMemoListViewController: BaseHomeViewController<MemosHomeBaseView> {
    
    var dataSource: UICollectionViewDiffableDataSource<Folder,Memo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        collectionViewDataSource()
        snapShot()
    }
    deinit {
        print("AllMemoListViewController",self)
    }
    
}


// MARK: 데이터 소스
extension AllMemoListViewController {
    private func collectionViewDataSource(){
        let cellRegister = UICollectionView.CellRegistration<MemoSimpleCollectionViewCell,Memo>{
            [weak self] cell, indexPath, item in
            guard self != nil else { return }
            cell.titleLabel.text = item.title
            cell.dateLabel.text = DateFormetters.shared.localDate(item.regdate)
            cell.subTitleLabel.text = item.contents
            let image = FileManagers.shard.loadImageMarkerImage(memoId: item.id.stringValue)
            if let image {
                cell.imageView.image = UIImage(contentsOfFile: image)
            }else {
                cell.imageView.image = UIImage(named: "Image")
            }
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Folder,Memo>(collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: itemIdentifier)
        })
    }
}

extension AllMemoListViewController {
    //MARK: SnapShot
    private func snapShot(){
        if let data = homeView.allMemoViewModel.outPutTrigger.value {
            var snaphot = NSDiffableDataSourceSnapshot<Folder   ,Memo>()
            snaphot.appendSections([data.folder])
            snaphot.appendItems(data.list,toSection: data.folder)
            dataSource?.apply(snaphot, animatingDifferences: true)
        }
    }
    private func subscribe(){
        SingleToneDataViewModel.shared.shardFolderOb.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
            homeView.allMemoViewModel.inputTrigger.value = folder
        }
        homeView.allMemoViewModel.outPutTrigger.bind { [weak self ] result in
            guard result != nil else { return }
            guard let self else { return }
            snapShot()
        }
    }
}
