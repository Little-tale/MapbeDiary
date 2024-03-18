//
//  AllMemoListViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
// MARK: 사용할 모델

protocol LocationDelegate: AnyObject {
    func getLocationInfo(memo: LocationMemo)
}

class AllMemoLocationListViewController: BaseHomeViewController<LacationMemosHomeBaseView> {
    
    weak var locationDelegate: LocationDelegate?
    
    var dataSource: UICollectionViewDiffableDataSource<Folder,LocationMemo>?
    
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
    
    func emptyImageSetting(){
        let width = view.bounds.width
        homeView.emptyLauout(screen: width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyImageSetting()
    }
}


// MARK: 데이터 소스
extension AllMemoLocationListViewController {
    private func collectionViewDataSource(){
        let cellRegister = UICollectionView.CellRegistration<MemoSimpleCollectionViewCell,LocationMemo>{
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
                cell.imageView.image = .emptyAnnotation
            }
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Folder,LocationMemo>(collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: itemIdentifier)
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeView.allMemoViewModel.reloadTrigger.value = ()
    }
    
    private func test(){
        homeView.swifeAction = {[weak self] indexPath in
            
            let action = UIContextualAction(style: .destructive, title: "제거") { action, view, whatif in
                guard let data = self?.dataSource?.itemIdentifier(for: indexPath) else { return }
                self?.deleteAlert(memo: data)
                whatif(true)
            }
            let modifyAction = UIContextualAction(style: .normal, title: "세부수정") { action, view, whatIf in
                guard let data = self?.dataSource?.itemIdentifier(for: indexPath) else { return }
                self?.modifyAction(memo: data)
                whatIf(true)
            }
            
            modifyAction.backgroundColor = .systemGreen
            
            return UISwipeActionsConfiguration(actions: [action, modifyAction])
        }
    }
    
    private func deleteAlert(memo: LocationMemo){
        showAlert(title: "삭제", message: "지우시면 복구하실수 없습니다!", actionTitle: "삭제하기") { [weak self] action in
            guard let self else {return}
            homeView.allMemoViewModel.removeMemo.value = memo
        }
    }
    private func modifyAction(memo: LocationMemo) {
        print(#function)
        locationDelegate?.getLocationInfo(memo: memo)
        dismiss(animated: true)
    }
    
}

extension AllMemoLocationListViewController {
    //MARK: SnapShot
    private func snapShot(){
        if let data = homeView.allMemoViewModel.outPutTrigger.value {
            var snaphot = NSDiffableDataSourceSnapshot<Folder   ,LocationMemo>()
            
            snaphot.appendSections([data.folder])
            snaphot.appendItems(data.Memo,toSection: data.folder)
            
            // MARK: diff를 계산하지 않고 Reload한다.
            // dataSource?.apply(snaphot) // 변화를 감지 못해 서울시
            dataSource?.applySnapshotUsingReloadData(snaphot)
        }
    }
    private func subscribe(){
        SingleToneDataViewModel.shared.allListFolderOut.bind { [weak self] folder in
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
        homeView.allMemoViewModel.realmError.bind {
            [weak self] error in
            guard let error else { return }
            guard let self else { return }
            showAPIErrorAlert(repo: error)
        }
    }
    
}


