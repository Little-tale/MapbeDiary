//
//  SettingViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit



final class SettingViewController: BaseHomeViewController<SettingHomeView> {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<SettingSection,SettingModel>
    
    private typealias CellRegistry = UICollectionView.CellRegistration<UICollectionViewCell,SettingModel>
    
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationLeftButtonSetting() // 네비게이션 좌측 버튼세팅
        settingMainNaviTitleView() // 네비게이션 중앙 설정
        settingDataSource() // 컴포지셔널 데이터 소스 세팅
        settingSnapShot() // 스냅샷 세팅
        delegateSetting()
    }
    
    private func delegateSetting(){
        homeView.collectionView.delegate = self
    }
}
// MARK: 네비게이션 LeftBarButtonSetting
extension SettingViewController {
    private func navigationLeftButtonSetting(){
        
        let button = CustomLocationButton(frame: .zero, imageType: .naviBackButton)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            leftBackButton()
        }), for: .touchUpInside)
        
        let leftUIBarButton = UIBarButtonItem(customView: button)
        
       navigationItem.leftBarButtonItem = leftUIBarButton
    }
    
    private func leftBackButton(){
        print(#function)
        SingleToneDataViewModel.shared.shardFolderOb.value = SingleToneDataViewModel.shared.shardFolderOb.value
        dismiss(animated: true)
    }
    
    private func settingMainNaviTitleView(){
        navigationItem.title = "설정"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .bold)]
    }
    
}


// MARK: 컴포지션 데이타 소스
extension SettingViewController {
    private func settingDataSource(){
        let collectionViewCellRegist:CellRegistry = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var configu = UIListContentConfiguration.valueCell()
            
            configu.text = itemIdentifier.title
            configu.secondaryText = itemIdentifier.detail
            cell.contentConfiguration = configu
            cell.backgroundColor  = .blue
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .darkKarky
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: collectionViewCellRegist, for: indexPath, item: itemIdentifier)
            cell.backgroundColor = .wheetPink
            
            return cell
        })
    }
}

// MARK: 컴포지션 스냅샷 세팅
extension SettingViewController {
    private func settingSnapShot(){
        
        var snapShot = NSDiffableDataSourceSnapshot<SettingSection,SettingModel> ()
        
        snapShot.appendSections(SettingSection.allCases)
        
        snapShot.appendItems(SettingSection.setting.data, toSection: .setting)
        
        snapShot.appendItems(SettingSection.info.data, toSection: .info)
        
        snapShot.appendItems(SettingSection.delete.data, toSection: .delete)
        
        dataSource?.apply(snapShot, animatingDifferences: true)
    }
}

extension SettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item.actionType {
        case .appVersion:
            print("버전")
            break
        case .termsAndConditions:
            print("약관 / ") // 웹뷰로 노션페이지 보내주기
            let vc = SettingWebViewController()
            vc.homeView.viewModel.inputSettingActionType.value = item.actionType
            navigationController?.pushViewController(vc, animated: true)
            break
        case .customerSupport:
            print("고객센터") // 노션페이지
            
            let vc = SettingWebViewController()
            vc.homeView.viewModel.inputSettingActionType.value = item.actionType
            navigationController?.pushViewController(vc, animated: true)
        case .initialize:
            print("초기화") // 완전 초기화
        }
    }
}


