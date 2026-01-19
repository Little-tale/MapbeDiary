//
//  SettingViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class SettingViewController: ReactorBaseViewController<SettingViewReactor,SettingVCView>, ToastPro {
    
    // MARK: property
    
    private typealias DataSource = UICollectionViewDiffableDataSource<SettingSection,SettingModel>
    
    private typealias CellRegistry = UICollectionView.CellRegistration<UICollectionViewCell,SettingModel>
    
    private var dataSource: DataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.backgroundColor = .wheetSideBrown
        navigationLeftButtonSetting() // 네비게이션 좌측 버튼세팅
        settingMainNaviTitleView() // 네비게이션 중앙 설정
        settingDataSource() // 컴포지셔널 데이터 소스 세팅
        settingSnapShot() // 스냅샷 세팅
    }
    
    override func bind(reactor: SettingViewReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .compactMap { $0.realmError }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, error in
                LoadingWindow.shared.hide()
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successTrigger }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, bool in
                LoadingWindow.shared.hide()
                owner.mainView.makeToast("Deleting_completion_title".localized)
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: SettingViewReactor) {
        
        mainView.collectionView.rx
            .itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                owner.dataSource?.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, item in
                
                switch item.actionType {
                case .appVersion:
                    print("버전")

                case .termsAndConditions: // 웹뷰로 노션 페이지 보내주기
                    print("약관 / ")
                    if !NetWorkServiceMonitor.shared.isConnected {
                        owner.networkCheckToast()
                        return
                    }
                    
                    owner.sendSettingWebViewController(type: item.actionType)
                    
                case .customerSupport: // 웹뷰로 노션 페이지 보내주기
                    print("고객센터")
                    if !NetWorkServiceMonitor.shared.isConnected {
                        owner.networkCheckToast()
                        return
                    }
                    owner.sendSettingWebViewController(type: item.actionType)
                    
                case .initialize: // 완전 초기화
                    print("초기화")
                    owner.CanICheckDelete()
                }
            }
            .disposed(by: disposeBag)
        
        mainView.backButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Helpers
extension SettingViewController {
    
    private func CanICheckDelete(){
        showAlertHandlerCancel(
            title: MapTextSection.delete.alertTitle,
            message: MapTextSection.delete.alertMessage,
            actionTitle: MapTextSection.delete.actionTitle
        ) { [weak self] _ in
            guard let self else { return }
            LoadingWindow.shared.show(title: "삭제중")
            reactor?.action.onNext(.callDeleteInfo)
        }
    }
    
    private func networkCheckToast(){
        showToastBody(
            title: "API_Check_Title".localized,
            message: "API_error_Request".localized
        )
    }
    
    private func sendSettingWebViewController(type: SettingActionType) {
        
        let vc = SettingWebViewController(reactor: SettingWebReactor())
        
        vc.sendAction(type: type)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: 네비게이션 LeftBarButtonSetting
extension SettingViewController {
    /// 좌측 버튼 설정
    private func navigationLeftButtonSetting(){
        
        let button = CustomLocationButton(frame: .zero, imageType: .naviBackButton)
        
        let leftUIBarButton = UIBarButtonItem(customView: button)
        
        navigationItem.leftBarButtonItem = leftUIBarButton
        
        button.rx.tap
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }

    /// 네비게이션 타이틀 세팅
    private func settingMainNaviTitleView(){
        navigationItem.title = "Setting_title".localized
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont.systemFont(
                ofSize: 20, weight: .bold
            ),
            NSAttributedString.Key.foregroundColor : UIColor.wheetBlack
        ]
    }
    
}


// MARK: CollectionView Settings
extension SettingViewController {
    
    private func settingDataSource(){
        let reg = settingCellRegister()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: mainView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
        
            let cell = collectionView.dequeueConfiguredReusableCell(using: reg, for: indexPath, item: itemIdentifier)
            
            cell.backgroundColor = .wheetPink
            
            return cell
        })
    }
    
    private func settingCellRegister() -> CellRegistry {
        let cellRegister: CellRegistry = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            var config = UIListContentConfiguration.valueCell()
            
            config.text = itemIdentifier.title
            config.secondaryText = itemIdentifier.detail
            
            cell.contentConfiguration = config
            cell.backgroundColor  = .blue
        }
        return cellRegister
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
