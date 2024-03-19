//
//  AboutMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import UIKit
import PhotosUI
import AVFoundation
import Toast

final class AboutMemoViewController: BaseHomeViewController<MemoSettingBaseView> {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        settingSaveButton() // Save
        collectionViewDelegatDatasource()
        imageSettingButtonAction() // imageAddButton
        deleteButtonAction() // deleteButton
        dismisButtonClicked()
        subscribe()
    
        homeView.memoTextView.text = homeView.memoViewModel.inputModel.value?.inputMemoMeodel?.detailContents ?? ""
    
        
    }
    
    private func collectionViewDelegatDatasource(){
        homeView.colletionView.delegate = self
        homeView.colletionView.dataSource = self
    }
    
}

// MARK: Button Actions
extension AboutMemoViewController {
    
    private func settingSaveButton(){
        homeView.saveButton.addAction(UIAction(handler: {
            [weak self] _ in
            guard let self else { return }
            print("버튼클릭")
            homeView.memoViewModel.emptyModel.value.memoText = homeView.memoTextView.text

            homeView.memoViewModel.saveInput.value = ()
        }), for: .touchUpInside)
    }
    
    private func imageSettingButtonAction(){
        homeView.addImageButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            // 1. 액션시트를 띄우기
            showPhotoActionSheet()
        }), for: .touchUpInside)
    }
    
    private func deleteButtonAction(){
        homeView.deleteButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            showdeletAlert()
        }), for: .touchUpInside)
    }
    
    private func dismisButtonClicked(){
        homeView.backButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self else { return }
            showAlert(title: MapTextSection.dismiss.alertTitle, message: MapTextSection.dismiss.alertMessage, actionTitle: MapTextSection.dismiss.actionTitle) { _ in
                self.dismiss(animated: true)
            }
        }), for: .touchUpInside)
    }
}


// ActionSheet
extension AboutMemoViewController {
    func showPhotoActionSheet() {
        let max = homeView.memoViewModel.emptyModel.value.viewImageData.count
        
        let alert = UIAlertController(title: "사진 가져오기", message: nil, preferredStyle: .actionSheet)
    
        let camera = ActionRouter.camera.actions {
            [weak self] in
            guard let self else { return }
            print("assad???? ")
            if checkMax(max: max){
                checkCameraAuthorization()
            }
        }
        let gellery = ActionRouter.gallery.actions {
            [weak self] in
            guard let self else { return }
            if checkMax(max: max){
                checkUserPhotoAuthorization(max: homeView.memoViewModel.maxImageCount - max )
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(camera)
        alert.addAction(gellery)
        alert.addAction(cancel)

        present(alert, animated: true)
    }
    
    private func checkMax(max: Int) -> Bool{
        print("MAX : \(max)")
        if max == homeView.memoViewModel.maxImageCount {
            showToastBody(title: "이미지 제한", message: "이미지는 총 3개만 추가하실수 있어요!", complite: nil)
            return false
        }
        return true
    }
    
    func showPhotoViewActionSheet(index: IndexPath){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self else { return }
            if (homeView.memoViewModel.inputModel.value?.inputMemoMeodel) != nil {
                // MARK: 여기서 부터 로직을 수정
                homeView.memoViewModel.removeImage.value = index
                homeView.memoViewModel.emptyModel.value.imageModify = true
            } else {
                homeView.memoViewModel.emptyModel.value.viewImageData.remove(at: index.item)
                
            }
        }
        
        let photoViewAction = UIAlertAction(title: "뷰어로 이동", style: .default) { [weak self] _ in
            guard let self else { return }
            let imageDatas = homeView.memoViewModel.emptyModel.value.viewImageData
            
            let imageData = imageDatas[index.item]
            let vc = CustomImageViewer()
            vc.loadImage(data: imageData)
            DispatchQueue.main.async {
                [ weak self ] in
                guard let self else { return }
                present(vc, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(photoViewAction)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            [ weak self ] in
            guard let self else { return }
            present(alert, animated: true)
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
    
}


// MARK: UIImagePicekerDelegate
extension AboutMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // MARK: 회고에 작성
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let pickImage = info[.originalImage] as? UIImage else {
            showAlert(title: cameraError.titleString, message: cameraError.messageString)
            return
        }
        print(pickImage)
        if let imageData = pickImage.jpegData(compressionQuality: 1) {
            handleImageAction(data: imageData)
            
        }
    }
}

// MARK: PHPickerViewControllerDelegate
extension AboutMemoViewController:PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
    
        for result in results {
            if !result.itemProvider.canLoadObject(ofClass: UIImage.self){
                return // UIImage로 변환 실패
            }
            result.itemProvider.loadObject(ofClass: UIImage.self) {[weak self] image, error in
                guard let image = image as? UIImage else {return}
                DispatchQueue.main.async {
                    guard let self else { return }
                    if error != nil {
                        self.showAlert(title: "이미지 로드실패", message: "테스트")
                        return
                    }
                    guard let data = image.jpegData(compressionQuality: 1) else { print("Data Fail")
                        
                        self.showAlert(title: "이미지 로드실패", message: "테스트")
                        return
                    }
                    
                    self.handleImageAction(data: data)
                }
            }
            
        }
        
        print(results)
    }
    
}

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
    func showdeletAlert(){
        let alert = UIAlertController(title: MapTextSection.delete.alertTitle, message: MapTextSection.delete.alertMessage, preferredStyle: .alert)
        
        let action = UIAlertAction(title: MapTextSection.delete.actionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            homeView.memoViewModel.removiewInput.value = ()
            homeView.memoViewModel.emptyModel.value.imageModify = true
        }
        
        let cancel = UIAlertAction(title: MapTextSection.delete.cancelTitle, style: .default)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    // 뒤로가기 시도시
    
    
    
}

// MARK: 이미지 삭제 추가 Action -> Z인덱스
extension AboutMemoViewController {
    // MARK: 이때도 수정해야해
    private func handleImageAction(data: Data){
        if homeView.memoViewModel.emptyModel.value.inputMemoMeodel != nil {
   
            homeView.memoViewModel.emptyModel.value.viewImageData.append(data)
            
            homeView.memoViewModel.emptyModel.value.imageModify = true
            
            
        } else {
            // print(data)
            homeView.memoViewModel.emptyModel.value.viewImageData.append(data)
            print("####",homeView.memoViewModel.emptyModel.value.viewImageData)
        }
        
        
    }
}

extension AboutMemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("SSS",homeView.memoViewModel.emptyModel.value.viewImageData.count)
        
        return homeView.memoViewModel.emptyModel.value.viewImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlyImageCollectionViewCell.reusebleIdentifier, for: indexPath) as? OnlyImageCollectionViewCell else {
            print("테이블뷰 에러")
            return UICollectionViewCell()
        }
    
        let data = homeView.memoViewModel.emptyModel.value.viewImageData[indexPath.item]
        
        DispatchQueue.main.async {
            cell.backgoundImage.image = UIImage(data: data)
        
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showPhotoViewActionSheet(index: indexPath)
    }
}

extension AboutMemoViewController: ToastPro {
    
    // MARK: 최대 선택할수 있는 개수를 통해 제한
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
        homeView.memoViewModel.dismissOutPut.bind { [weak self] void  in
            guard let self else { return }
            guard void != nil else { return }
            dismiss(animated: true)
        }
        
        homeView.memoViewModel.repoErrorPut.bind { [ weak self ] error in
            guard let self else { return }
            guard let error else { return }
            showAPIErrorAlert(repo: error)
        }
        
        homeView.memoViewModel.emptyModel.bind { [weak self] model in
            guard let self else { return }
            homeView.colletionView.reloadData()
        }
        homeView.memoViewModel.fileErrorPut.bind {[weak self] error in
            guard let self else { return }
            guard let error else { return }
            showAPIErrorAlert(file: error)
        }
        homeView.memoViewModel.successSave.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            dismiss(animated: true)
            NotificationCenter.default.post(name: .didSaveActionDetailMemo, object: nil)
        }
        homeView.memoViewModel.deletButtonHidden.bind { [weak self] bool in
            guard let self else { return }
            guard let bool else { return }
            homeView.deleteButton.isHidden = !bool
        }
        homeView.memoViewModel.warningTitle.bind { [weak self] textSection in
            guard let self else { return }
            guard let textSection else { return }
            showToastBody(title: textSection.alertTitle, message: textSection.alertMessage)
        }
    }
}

/*
 //        // lcationMemo 만 왔을때의 가정
 //       let first =  homeView.memoViewModel.repository.findFirstLocationMemo()
 //
 //        // MARK: location과 Memo가 같이 왔을때 가정
 //
 //        homeView.memoViewModel.inputModel.value = AboutMemoModel(inputLoactionInfo: first) //inputMemoMeodel: first?.detailMemos.first)
 //
 */
// 이게 하나씩 실시간 저장하는 거였을건데 기능 드랍
// homeView.memoViewModel.inputImage.value = data
//            let imageData = homeView.memoViewModel.emptyModel.value.iamgeData
//
//            homeView.memoViewModel.emptyModel.value.iamgeData.append(data)
//            let imageObject = ImageObject(index: imageData.count)
//            homeView.memoViewModel.emptyModel.value.removewimageObject?.append(imageObject)
