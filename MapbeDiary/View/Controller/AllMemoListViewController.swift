//
//  AllMemoListViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
// MARK: 사용할 모델
struct AllMemoModel {
    var folder: Folder
    var Memo: [Memo]
}

class AllMemoListViewController: BaseHomeViewController<MemosHomeBaseView> {
    
    var dataSource: UICollectionViewDiffableDataSource<Folder,Memo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDataSource()
        snapShot()
        navigationSetting()
        subscribe()
        test()
    }
    deinit {
        print("AllMemoListViewController",self)
    }
    func navigationSetting(){
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
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
            print("제발!!!!cellRegister",item.title)
            cell.subTitleLabel.text = item.contents
            let image = FileManagers.shard.loadImageOrignerMarker(memoId: item.id.stringValue)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeView.allMemoViewModel.reloadTrigger.value = ()
    }
    
    private func test(){
        homeView.deleteAction = {[weak self] indexPath in
            let action = UIContextualAction(style: .normal, title: "제거") { action, view, whatif in
                guard let data = self?.dataSource?.itemIdentifier(for: indexPath) else { return }
                print(data)
            }
            return UISwipeActionsConfiguration(actions: [action])
        }
    }
    
    private func deleteAlert(memo: Memo){
        showAlert(title: "삭제", message: "지우시면 복구하실수 없습니다!", actionTitle: "삭제하기") { [weak self] action in
            guard let self else {return}
            
        }
    }
    
}

extension AllMemoListViewController {
    //MARK: SnapShot
    private func snapShot(){
        if let data = homeView.allMemoViewModel.outPutTrigger.value {
            var snaphot = NSDiffableDataSourceSnapshot<Folder   ,Memo>()
            snaphot.appendSections([data.folder])
            snaphot.appendItems(data.Memo,toSection: data.folder)
            // MARK: diff를 계산하지 않고 Reload한다.
            dataSource?.applySnapshotUsingReloadData(snaphot)
//            dataSource?.apply(snaphot, animatingDifferences: true)
        }
    }
    private func subscribe(){
        SingleToneDataViewModel.shared.shardFolderOb.bind { [weak self] folder in
            guard let self else { return }
            guard let folder else { return }
            homeView.allMemoViewModel.inputTrigger.value = folder
        }
        
        homeView.allMemoViewModel.outPutTrigger.bind { [weak self ] result in
            guard let result else { return }
            guard let self else { return }
            snapShot()
            
            navigationItem.title = result.folder.folderName
        }

    }
}


