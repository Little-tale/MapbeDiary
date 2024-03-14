//
//  AboutMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import UIKit
import PhotosUI
import AVFoundation

final class AboutMemoViewController: BaseHomeViewController<MemoSettingBaseView> {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingSaveButton()
        collectionViewDelegatDatasource()
        imageSettingButtonAction()
        
        // lcationMemo 만 왔을때의 가정
        let first = homeView.memoViewModel.repository.findFirstLocationMemo()
        
        homeView.memoViewModel.inputLoactionInfo = first
    }
    
    private func collectionViewDelegatDatasource(){
        homeView.colletionView.delegate = self
        homeView.colletionView.dataSource = self
    }
    
   
}

// MARK: SaveButton and ChnageButton
extension AboutMemoViewController {
    private func settingSaveButton(){
        homeView.saveButton.addAction(UIAction(handler: {
            [weak self] _ in
            guard let self else { return }
            print("버튼클릭")
            homeView.memoViewModel.emptyModel.memoText = homeView.memoTextView.text
            homeView.memoViewModel.saveInput.value = ()
        }), for: .touchUpInside)
    }
    private func imageSettingButtonAction(){
        homeView.addImageButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            // 1. 액션시트를 띄우기
            
        }), for: .touchUpInside)
    }
}
// ActionSheet
extension AboutMemoViewController {
    func showActionSheet() {
        let alert = UIAlertController(title: "사진 가져오기", message: nil, preferredStyle: .actionSheet)
        
        let camera = ActionRouter.camera.actions {
            [weak self] in
            print("사진액션!")
            self?.checkCameraAuthorization()
        }
        let gellery = ActionRouter.gallery.actions {
            [weak self ] in
            print("gellery!")
            self?.checkUserPhotoAuthorization(max: 3 )
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(camera)
        alert.addAction(gellery)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

// MARK: Camera Authorization
extension AboutMemoViewController {
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self ] bool in
                guard let self else { return }
                if bool {
                    showImagePicker()
                } else {
                    cameraSettingAlert()
                }
            }
        case .restricted, .denied:
            cameraSettingAlert()
        case .authorized:
            showImagePicker()
        @unknown default:
            cameraSettingAlert()
        }
    }
    
    private func showImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
}
// MARK: UIImagePicekerDelegate
extension AboutMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //
    }
}

// MARK: PHPickerViewControllerDelegate
extension AboutMemoViewController:PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        <#code#>
    }
    
}

// MARK: Alerts
extension AboutMemoViewController {
    func cameraSettingAlert(){
        showAlert(title: MapAlertSection.camera.title, message: MapAlertSection.camera.message, actionTitle: MapAlertSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
}



extension AboutMemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.cornerRadius = 14
        cell.backgroundColor = .black
        return cell
    }
}

extension AboutMemoViewController {
    func checkUserPhotoAuthorization(max: Int) {
        
        var configurataion = PHPickerConfiguration()
        
        configurataion.selectionLimit = max
        
        configurataion.filter = .any(of: [.images])
        
        let phpPicker = PHPickerViewController(configuration: configurataion)
        
        phpPicker.delegate = self
        
        present(phpPicker, animated: true)
    }
}


extension AboutMemoViewController {
    func subscribe(){
        homeView.memoViewModel.successOutput.bind { [weak self] void  in
            guard let self else { return }
            guard let void else { return }
            // 성공시에는 disMiss
        }
        
        homeView.memoViewModel.repoErrorPut.bind { [ weak self ] error in
            guard let self else { return }
            guard let error else { return }
            showAPIErrorAlert(repo: error)
        }
    }
}



