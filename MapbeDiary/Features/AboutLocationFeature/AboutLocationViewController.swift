//
//  AboutLocationViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.

import UIKit
import RxSwift
import RxCocoa

protocol AboutModifyLocationDelegate: AnyObject {
    func getModifyInfo(with locationMemo: LocationMemoEntity)
}

final class AboutLocationViewController: ReactorBaseViewController<AboutLocationReactor, AboutLocationVCView> {
    
    // MARK: typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<DetailMemoEntity, URL>
    
    typealias CellRegister = UICollectionView.CellRegistration<OnlyImageCollectionViewCell, URL>
    
    typealias HeaderRegister = UICollectionView.SupplementaryRegistration<DetailMemoHeaderView>
    
    typealias FooterRegister = UICollectionView.SupplementaryRegistration<DetailMemoSeparatorFooterView>
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<DetailMemoEntity, URL>
    
    
    // MARK: Property
    
    private var dataSource: DataSource?
    private let imageCache = NSCache<NSString, UIImage>()
    weak var backDelegate: BackButtonDelegate?
    weak var locationDelegate: AboutModifyLocationDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataSource()
    }
    
    override func bind(reactor: AboutLocationReactor) {
        super.bind(reactor: reactor)
        
        reactor.state.map { $0.locationMemo }
            .compactMap { $0 }
            .bind(with: self) { owner, model in
                owner.mainView.memoDetailView.setData(data: model)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.detailMemos }
            .distinctUntilChanged()
            .bind(with: self) { owner, models in
                owner.applySnapShot(data: models)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$realmError)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$modifyRequest)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, event in
                owner.modifyMoveMemoVC(
                    memoID: event.memoID,
                    detailID: event.item.id
                )
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isEmptyDetails)
            .bind(with: self) { owner, trigger in
                owner.mainView.isEmptyView(isHidden: !trigger)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$successRemoveMemo)
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.dismissAction()
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: AboutLocationReactor) {
        
        rx.viewDidLoad
            .map { _ in AboutLocationReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.backButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismissAction()
            }
            .disposed(by: disposeBag)
        
        mainView.memoEmptyView.emptyButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.newDetailMemoAction()
            }
            .disposed(by: disposeBag)
        
        mainView.detailAddButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.newDetailMemoAction()
            }
            .disposed(by: disposeBag)
        
        mainView.allDeleteButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.showLocationDeleteAlert()
            }
            .disposed(by: disposeBag)
        
        mainView.memoDetailView.modifyLocationButton.rx
            .tap
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.modifyCheckAction()
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .itemSelected
            .compactMap { [weak self] indexPath in
                self?.dataSource?.itemIdentifier(for: indexPath)
            }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .compactMap { url in
                try? Data(contentsOf: url)
            }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
                owner.showImageViewer(with: data)
            }
            .disposed(by: disposeBag)
    }
    
    override func register() {
        mainView.collectionView.setCollectionViewLayout(makeLayout(), animated: true)
    }
}

// MARK: CollectionView
extension AboutLocationViewController {
    
    private func setDataSource() {
        let cellRegister = setCollectionViewCellRegister()
        
        dataSource = DataSource(
            collectionView: mainView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegister,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        )
        
        let headerRegister = setCollectionViewHeaderRegister()
        let footerRegister = setCollectionViewFooterRegister()
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegister,
                    for: indexPath
                )
            }
            if kind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerRegister,
                    for: indexPath
                )
            }
            return nil
        }
    }
    
    private func setCollectionViewCellRegister() -> CellRegister {
        let cellRegister = CellRegister { [weak self] cell, _, item in
            guard let self else { return }
            cell.setImage(from: item, cache: self.imageCache)
        }
        return cellRegister
    }
    
    private func setCollectionViewHeaderRegister() -> HeaderRegister {
        let headerRegister = HeaderRegister(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            
            guard let section = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else {
                return
            }
            
            supplementaryView.setData(
                data: DetailMemoHeaderView.SetData(
                    detail: section.detailContents,
                    regDate: section.regDate.localDate()
                )
            )
            
            supplementaryView.menuDeleteAction = {
                self?.showDetailDeleteAlert(data: section, index: indexPath.section)
            }
            
            supplementaryView.menuModifyAction = {
                self?.reactor?.action.onNext(.modifyRequest(section))
            }
        }
        
        return headerRegister
    }
    
    private func setCollectionViewFooterRegister() -> FooterRegister {
        return FooterRegister(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { _, _, _ in }
    }
    
    private func applySnapShot(data: [DetailMemoEntity]) {
        var snapShot = SnapShot()
        snapShot.appendSections(data)
        data.forEach { detail in
            snapShot.appendItems(detail.imagePaths, toSection: detail)
        }
        dataSource?.apply(snapShot, animatingDifferences: true)
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, _  in
            guard let self,
                  let datas = reactor?.currentState.detailMemos
            else { return nil }
            
            let hasImages = !(datas[section].imagePaths.isEmpty)
            return CollectionViewLayouts.makeImageCarouselSection(
                hasImages: hasImages,
                showsSeparator: true
            )
        }
    }
}

// MARK: Action
extension AboutLocationViewController {
    
    private func modifyMoveMemoVC(memoID: String, detailID: String) {
        let vc = AboutMemoViewController(
            reactor: AboutMemoReactor(
                memoID: memoID,
                detailMemoID: detailID
            )
        )
        
        vc.didSuccessMemo = { [weak self] in
            self?.reactor?.action.onNext(.reLoadData)
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    
    private func showDetailDeleteAlert(data: DetailMemoEntity, index: Int){
        let alert = UIAlertController(title: MapTextSection.delete.alertTitle, message: MapTextSection.delete.alertMessage, preferredStyle: .alert)
        
        let action = UIAlertAction(title: MapTextSection.delete.actionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            reactor?.action.onNext(.removeDetail(model: data, index: index))
        }
        
        let cancel = UIAlertAction(title: MapTextSection.delete.cancelTitle, style: .default)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    // 로케이션 기록 삭제시
    private func showLocationDeleteAlert() {
        let alert = UIAlertController(title: MapTextSection.delete.alertTitle, message: MapTextSection.delete.alertMessage, preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: MapTextSection.delete.actionTitle,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            reactor?.action.onNext(.removeRequest)
        }
        let cancel = UIAlertAction(
            title: MapTextSection.delete.cancelTitle,
            style: .default
        )
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    // 지역 수정 액션
    private func modifyCheckAction(){
        showAlertHandlerCancel(title: "수정", message: "장소를 수정 하러 가시겠습니까?", actionTitle: "이동하기") { [weak self] _ in
            guard let self else { return }
            guard let location = reactor?.currentState.locationMemo else { return }
            locationDelegate?.getModifyInfo(with: location)
        }
    }
    
    private func newDetailMemoAction(){
        guard let id = reactor?.currentState.memoID else {
            return
        }
        
        let vc = AboutMemoViewController(
            reactor: AboutMemoReactor(
                memoID: id,
                detailMemoID: nil
            )
        )
        
        vc.didSuccessMemo = { [weak self] in
            self?.reactor?.action.onNext(.reLoadData)
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func showImageViewer(with data: Data) {
        let vc = CustomImageViewer()
        vc.loadImage(data: data)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func dismissAction(){
        backDelegate?.backButtonClicked()
    }
}
