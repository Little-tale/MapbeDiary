//
//  AddMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import PhotosUI
import AVFoundation
import Toast

protocol BackButtonDelegate: AnyObject {
    func backButtonClicked()
}
struct addViewStruct {
    let lat: String
    let lon: String
    var folder: Folder
    
    init(lat: String, lon: String, folder: Folder) {
        self.lat = lat
        self.lon = lon
        self.folder = folder
    }
}

struct addViewOutStruct {
    var title: String
    let titlePlacHolder: String
    var content: String
    var phoneNumber: String?
    var folderimage: String
    var regDate = Date()
    var memoImage: UIImage?
    var folder: Folder
    var detailContents: String?
    
    init(title: String?, titlePlacHolder: String?, folder: Folder, folderImage: String? = nil) {
        var text = title ?? AddViewSection.defaultTitle
        print("text",text)
        if text == "" { text = AddViewSection.defaultTitle }
        self.title = text
        self.titlePlacHolder = titlePlacHolder ?? "Add_title_text_fileld_text".localized
        self.folder = folder
        self.content = ""
        self.folderimage = folderImage ?? ImageSection.defaultFolderImage.rawValue
        
    }
}

final class AddMemoViewController: BaseHomeViewController<AddBaseView>{
    var addViewModel = AddViewModel()
    
    // delegate
    weak var backDelegate: BackButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.backgroundColor = .systemGreen
        print(RealmRepository().printURL())
        subscribe()
        navigationSetting()
        folderButtonSetting()
        
        homeView.AddTitleDateView.imageChangeButton.addTarget(self, action: #selector(changeImageButtonClicked), for: .touchUpInside)
        homeView.detailTextView.delegate = self
    }
    
    @objc
    func changeImageButtonClicked(_ sender: UIButton){
        print(#function)
        showActionSheet()
    }
    
    func showActionSheet(){
        let alert = UIAlertController(title: "사진 가져오기", message: nil, preferredStyle: .actionSheet)
        let camera = ActionRouter.camera.actions {
            [weak self] in
            print("사진액션!")
            self?.checkCameraAuthorization()
        }
        let gellery = ActionRouter.gallery.actions {
            [weak self ] in
            print("gellery!")
            self?.checkUserPhotoAuthorization()
        }
        
        alert.addAction(camera)
        alert.addAction(gellery)
        present(alert, animated: true)
    }
    
    func navigationSetting(){
        let saveButton = CustomButton.saveCreate(title: AddViewSection.saveButtonText, target: self, action: #selector(saveButtonClicked))
        let dismisButton = CustomButton.backCreate(target: self, action: #selector(backButtonClicked))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = dismisButton
    }
    
    func folderButtonSetting(){
        homeView.folderButton.addTarget(self, action: #selector(sendFolderViewController), for: .touchUpInside)
    }
    
    @objc
    func sendFolderViewController(){
        print(#function)
    }
    
    @objc
    func saveButtonClicked(){
        print(#function)
        homeView.textFieldList.forEach { [weak self] textfield in
            guard let self else { return }
            var value = addViewModel.urlSuccessOutPut.value
            switch textfield.tag {
            case 0:
                var text = textfield.text ?? AddViewSection.defaultTitle
                if text == "" { text = AddViewSection.defaultTitle }
                value?.title = text
            case 1:
                value?.content = textfield.text ?? ""
            case 2:
                value?.phoneNumber = textfield.text ?? ""
            default:
                break
            }
            addViewModel.urlSuccessOutPut.value = value
        }
        addViewModel.saveButtonTrigger.value = ()
        backDelegate?.backButtonClicked()
    }
    deinit {
        print("deinit",#function)
    }
}

extension AddMemoViewController {
    private func subscribe() {
        addViewModel.urlSuccessOutPut.bind { [weak self] sussesModel in
            guard let self else {return}
            guard let sussesModel else {return}
            homeView.AddTitleDateView.titleTextField.placeholder = sussesModel.titlePlacHolder
            
            homeView.folderButton.configuration?.title = sussesModel.folder.folderName
            
            homeView.folderButton.configuration?.image = UIImage(named: sussesModel.folderimage)?.resizeImage(newWidth: 20)
            
            homeView.AddTitleDateView.dateLabel.text = DateFormetters.shared.localDate(sussesModel.regDate)
            
            if let image = sussesModel.memoImage {
                homeView.AddTitleDateView.imageView.image = image
            }
            
            print("@@",sussesModel.folder.folderName)
        }
        
        addViewModel.urlErrorOutPut.bind { [weak self] error in
            guard let error else { return }
            guard let self else { return }
            showAPIErrorAlert(urlError: error)
        }
        
        addViewModel.realmError.bind { [weak self] error in
            guard let error else { return }
            guard let self else { return }
            showAPIErrorAlert(repo: error)
        }
       
    }
}

extension AddMemoViewController {
    @objc
    func backButtonClicked() {
        // ismiss(animated: true)
        backDelegate?.backButtonClicked()
    }
    
}

// MARK: imagePicker
extension AddMemoViewController {
    func checkCameraAuthorization() {
        checkedAutCamera()
    }
    func checkedAutCamera(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: // 한번도 혹은 아무튼 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] bool in
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
    
    // MARK: goSetting
    func cameraSettingAlert(){
        showAlert(title: MapAlertSection.camera.title, message: MapAlertSection.camera.message, actionTitle: MapAlertSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    
    // MARK: ImagePicker Open
    func showImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}
// MARK: PHP피커 딜리게이트
extension AddMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let pickImage = info[.originalImage] as? UIImage else {
            showAlert(title: cameraError.titleString, message: cameraError.messageString)
            return
        }
        addViewModel.urlSuccessOutPut.value?.memoImage = pickImage
    }
}

// MARK: PHP 피커
extension AddMemoViewController {
    func checkUserPhotoAuthorization() {
        var configurataion = PHPickerConfiguration()
        configurataion.selectionLimit = 1
        configurataion.filter = .any(of: [.images])
        let phpPicker = PHPickerViewController(configuration: configurataion)
        phpPicker.delegate = self
        present(phpPicker, animated: true)
    }
}

extension AddMemoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let firstResults = results.first,
              firstResults.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        firstResults.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                guard let image = image as? UIImage else {return}
                print(image)
                var value = self?.addViewModel.urlSuccessOutPut.value
                value?.memoImage = image
                self?.addViewModel.urlSuccessOutPut.value = value
            }
        }
    }
}

extension AddMemoViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        var value = addViewModel.urlSuccessOutPut.value
        value?.detailContents = textView.text
        addViewModel.urlSuccessOutPut.value = value
        print("$$$",value?.detailContents)
    }
    
}
