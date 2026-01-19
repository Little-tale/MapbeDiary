//
//  AboutMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class AboutMemoViewController: ReactorBaseViewController<AboutMemoReactor,AboutMemoVCView>, ToastPro {
    
    enum PhotoActionType {
        case camera
        case gallery
        case cancel
        
        var title: String {
            switch self {
            case .camera:
                return "Authority_Camera".localized
            case .gallery:
                return "Authority_Gallery".localized
            case .cancel:
                return "Cancel_check_title".localized
            }
        }
    }
    
    private let photoManager = PhotosManager()
    
    var didSuccessMemo: (() -> Void)?
    
    override func bind(reactor: AboutMemoReactor) {
        super.bind(reactor: reactor)
        
        reactor.pulse(\.$showPhotoActionSheet)
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showImageAskActionSheet()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showAlreadyMaxImages)
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showAlreadyMaxToast()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showImageViewer)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
                owner.showImageViewer(data: data)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$realmError)
            .compactMap { $0 }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$fileManagerError)
            .compactMap { $0 }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(file: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.imageDatas }
            .distinctUntilChanged()
            .bind(
                to: mainView.collectionView.rx.items(
                    cellIdentifier: OnlyImageCollectionViewCell.reusableIdentifier,
                    cellType: OnlyImageCollectionViewCell.self
                )
            ) { _, item, cell in
                cell.setData(data: item)
            }
            .disposed(by: disposeBag)
            
        reactor.state.map { $0.currentTextViewText }
            .distinctUntilChanged()
            .bind(with: self) { owner, text in
                owner.mainView.memoTextView.text = text
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$didSaveSuccess)
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.didSuccessMemo?()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$didRemoveSuccess)
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.didSuccessMemo?()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.deleteButtonHidden }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, trigger in
                owner.mainView.deleteButton.isHidden = trigger
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.maxTextCount }
            .take(1)
            .bind(with: self) { owner, count in
                owner.mainView.memoTextView.maxCount = count
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showWarningToast)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, event in
                owner.showToastBody(
                    title: event.title,
                    message: event.message,
                    completion: nil
                )
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: AboutMemoReactor) {
        rx.viewDidLoad
            .map { _ in AboutMemoReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.saveButton.rx
            .tap
            .map{ _ in AboutMemoReactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.addImageButton.rx
            .tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map{ _ in AboutMemoReactor.Action.addImageButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.deleteButton.rx
            .tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showDeleteAlert()
            }
            .disposed(by: disposeBag)
        
        mainView.backButton.rx
            .tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showBackButtonTappedAfterAlert()
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .itemSelected
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self) { owner, indexPath in
                owner.tappedImageCell(index: indexPath)
            }
            .disposed(by: disposeBag)
        
        mainView.memoTextView.textView.rx.text
            .orEmpty
            .map{ text in AboutMemoReactor.Action.setCurrentText(text: text)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    override func register() {
        mainView.collectionView.register(
            OnlyImageCollectionViewCell.self,
            forCellWithReuseIdentifier: OnlyImageCollectionViewCell.reusableIdentifier
        )
    }
}

// MARK: Helpers
extension AboutMemoViewController {
    
    private func showBackButtonTappedAfterAlert() {
        showAlert(
            title: MapTextSection.dismiss.alertTitle,
            message: MapTextSection.dismiss.alertMessage,
            actionTitle: MapTextSection.dismiss.actionTitle
        ) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    private func showImageViewer(data: Data) {
        let vc = CustomImageViewer()
        vc.loadImage(data: data)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}


// ActionSheet
extension AboutMemoViewController {
    
    private func showImageAskActionSheet(){
        guard let reactor else { return }
        
        let alert = UIAlertController(
            title: MapTextSection.bringPhoto.alertTitle,
            message: nil, preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(
            title: PhotoActionType.camera.title,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            checkCameraAccessWithLogic()
        }
        
        let count = reactor.currentState.imageMaxCount - reactor.currentState.imageDatas.count
        
        let galleryAction = UIAlertAction(
            title: PhotoActionType.gallery.title,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            startGallery(count: count)
        }
        
        let cancel = UIAlertAction(
            title: PhotoActionType.cancel.title,
            style: .cancel
        )
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func checkCameraAccessWithLogic() {
        Task { @MainActor in
            let result = await photoManager.checkCameraPermission()
            
            if result {
                do {
                    let images = try await photoManager.pickFromCamera(
                        presenter: self
                    )
                    
                    guard let image = images?.first else {
                        return
                    }
                    
                    await sendImage([image])
                } catch {
                    await MainActor.run {
                        showAlert(
                            title: "Error",
                            message: "카메라 여는중 오류가 발생하였습니다."
                        )
                    }
                }
                
            } else {
                goCameraSettingAlert()
            }
        }
    }
    
    private func sendImage(_ images: [UIImage]) async {
        var datas: [Data] = []

        for image in images {
            guard let data = await image.onlyCompressImage(
                type: .jpeg,
                targetMB: 5
            ) else {
                print("압축 실패")
                return
            }
            datas.append(data)
        }

        reactor?.action.onNext(.sendImages(datas))
    }
    
    private func startGallery(count: Int) {
        Task { @MainActor in
            do {
                let result = try await photoManager.pickFromLibrary(
                    presenter: self,
                    maxSelection: count
                )
                guard let images = result else {
                    return
                }
                
                await sendImage(images)
            } catch {
                print(error)
            }
        }
    }

    private func showAlreadyMaxToast(){
        showToastBody(
            title: "Alert_image_max_title".localized,
            message: "Alert_image_max_detail".localized,
            completion: nil
        )
    }
    
    func tappedImageCell(index: IndexPath){
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: "Alert_delete".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            reactor?.action.onNext(.sendRemoveImageIndex(index: index.item))
        }
        
        let photoViewAction = UIAlertAction(
            title: "Alert_go_viewer".localized,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            reactor?.action.onNext(.requestShowImage(index: index.item))
        }
        
        let cancel = UIAlertAction(title: "Cancel_check_title".localized, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(photoViewAction)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            [ weak self ] in
            guard let self else { return }
            present(alert, animated: true)
        }
    }
    
    private func goCameraSettingAlert(){
        showAlert(title: MapTextSection.camera.alertMessage, message: MapTextSection.camera.actionTitle, actionTitle: MapTextSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
}




// MARK: PHPickerViewControllerDelegate

// MARK: Alerts
extension AboutMemoViewController {
    /// 카메라 세팅시
    func cameraSettingAlert(){
        showAlert(title: MapTextSection.camera.alertTitle, message: MapTextSection.camera.alertMessage, actionTitle: MapTextSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    /// 지우기 시도시
    func showDeleteAlert(){
        let alert = UIAlertController(
            title: MapTextSection.delete.alertTitle,
            message: MapTextSection.delete.alertMessage,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: MapTextSection.delete.actionTitle,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            reactor?.action.onNext(.removeTapped)
        }
        
        let cancel = UIAlertAction(
            title: MapTextSection.delete.cancelTitle,
            style: .default
        )
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
