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


struct addViewOutStruct {
    var title: String
    var titlePlacHolder: String
    var content: String
    var phoneNumber: String?
    var folderimage: String
    var regDate = Date() // 일단 대기
    var memoImage: UIImage?

    var folder: Folder
    var memoId: String?
    
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

struct memoModifyOutstruct {
    var title: String
    var content: String?
    var phoneNumber: String?
    var folderimage: String?
    var regDate: Date
    var markerImage: UIImage?
    var folder: Folder
    var locationMemoId: String
    var modiFy = false
    
    init(memo: LocationMemo, folder:Folder) {
        self.title = memo.title
        self.content = memo.contents
        self.phoneNumber = memo.phoneNumber
        self.regDate = memo.regdate
        self.folder = folder
        self.locationMemoId = memo.id.stringValue
        
        if let iamgePath = FileManagers.shard.loadImageMarkerImage(memoId: memo.id.stringValue) {
            markerImage = UIImage(contentsOfFile: iamgePath)
        }
        
    }
}

final class AddLocationMemoViewController: BaseHomeViewController<AddBaseView>{
    
    var addViewModel = AddViewModel()
    
    // delegate
    weak var backDelegate: BackButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(RealmRepository().printURL())
        subscribe()
        folderButtonSetting()
        buttonActionSetting()
        backViewSettin()
        homeView.AddTitleDateView.imageChangeButton.addTarget(self, action: #selector(changeImageButtonClicked), for: .touchUpInside)
    }
    
    @objc
    func changeImageButtonClicked(_ sender: UIButton){
        print(#function)
        showActionSheet()
    }
    private func backViewSettin(){
        homeView.backgroundColor = .skinSet
    }
    
    func showActionSheet(){
        let alert = UIAlertController(title: MapTextSection.bringPhoto.alertTitle, message: nil, preferredStyle: .actionSheet)
        let camera = ActionRouter.camera.actions {
            [weak self] in
            
            self?.checkCameraAuthorization()
        }
        let gellery = ActionRouter.gallery.actions {
            [weak self] in
            
            self?.checkUserPhotoAuthorization()
        }
        let cancel = ActionRouter.cancel.cancel
        
        alert.addAction(camera)
        alert.addAction(gellery)
        alert.addAction(cancel)
        present(alert, animated: true)
        
        
    }
    
    func buttonActionSetting() {
        homeView.backButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            backButtonClicked()
        }), for: .touchUpInside)
        
        homeView.saveButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            saveButtonClicked()
        }), for: .touchUpInside)
    }
    
    // MARK: 폴더버튼 액션
    func folderButtonSetting(){
        homeView.folderButton.addTarget(self, action: #selector(sendFolderViewController), for: .touchUpInside)
    }
    
    @objc
    func sendFolderViewController(){
        print(#function)
    }
    

    func saveButtonClicked(){
        print(#function)
        homeView.textFieldList.forEach { [weak self] textfield in
            guard let self else { return }
            var value = addViewModel.urlSuccessOutPut.value
            var modify = addViewModel.modifyEnd
            switch textfield.tag {
            case 0:
                value?.title = titleTestter(textField: textfield)
                modify?.title = titleTestter(textField: textfield)
            case 1:
                value?.content = textfield.text ?? ""
                modify?.content = textfield.text
            case 2:
                value?.phoneNumber = textfield.text ?? ""
                modify?.phoneNumber = textfield.text
            default:
                break
            }
            if addViewModel.urlSuccessOutPut.value != nil {
                addViewModel.urlSuccessOutPut.value = value
            } else {
                addViewModel.modifyEnd = modify
            }
        }
        addViewModel.saveButtonTrigger.value = ()
        
        backDelegate?.backButtonClicked()
        
        SingleToneDataViewModel.shared.shardFolderOb.value =  SingleToneDataViewModel.shared.shardFolderOb.value
    }
   
    func titleTestter(textField : UITextField) -> String{
        // 1. 텍스트가 비어있는지 부터
        if let textFieldText = textField.text,
           textFieldText.isEmpty {
            // 2. 기본 플레이스 홀더와 비교
            if let placeHolder = textField.placeholder,
               placeHolder != "Add_title_text_fileld_text".localized {
                return placeHolder
            } else {
                return textField.placeholder ?? AddViewSection.defaultTitle
            }
        }
        if let title = textField.text {
            return title // ""
        }
        return textField.placeholder ?? AddViewSection.defaultTitle
    }
    
    deinit {
        print("deinit",#function)
    }
    
}

extension AddLocationMemoViewController {
    private func subscribe() {
        addViewModel.urlSuccessOutPut.bind { [weak self] sussesModel in
            guard let self else {return}
            guard let sussesModel else {return}
            homeView.AddTitleDateView.titleTextField.placeholder = sussesModel.titlePlacHolder
            
            homeView.folderButton.configuration?.title = MapTextSection.beginningSoon
            // MARK: 업데이트 사항
            // sussesModel.folder.folderName
            
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
        
        addViewModel.memoSuccessOutPut.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            
            homeView.folderButton.configuration?.title = model.folder.folderName
            
            if let folderImagePath = FileManagers.shard.findFolderImage(folderId: model.folder.id.stringValue) {
                
                homeView.folderButton.configuration?.image = UIImage(contentsOfFile: folderImagePath)?.resizeImage(newWidth: 20)
            } else {
                homeView.folderButton.configuration?.image = UIImage(named: ImageSection.defaultFolderImage.rawValue)?.resizeImage(newWidth: 20)
            }
            
            homeView.AddTitleDateView.dateLabel.text = DateFormetters.shared.localDate(model.regDate)
            // 이미지
            homeView.AddTitleDateView.imageView.image = model.markerImage ?? UIImage(named: ImageSection.defaultMarkerImage.rawValue)
            // 타이틀
            homeView.AddTitleDateView.titleTextField.text = model.title
            // 간편메모
            homeView.AddTitleDateView.simpleMemoTextField.text = model.content
            // 전화번호
            homeView.phoneTextField.text = model.phoneNumber
        }
        
        
       
    }
}

extension AddLocationMemoViewController {

    func backButtonClicked() {
        // ismiss(animated: true)
        backDelegate?.backButtonClicked()
    }
    
}

// MARK: imagePicker
extension AddLocationMemoViewController {
    
    func checkCameraAuthorization() {
        checkedAutCamera()
    }
    private func checkedAutCamera(){
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
        showAlert(title: MapTextSection.camera.alertMessage, message: MapTextSection.camera.actionTitle, actionTitle: MapTextSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    
    // MARK: ImagePicker Open
    private func showImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}
// MARK: PHP피커 딜리게이트
extension AddLocationMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
      
        guard let pickImage = info[.originalImage] as? UIImage else {
            showAlert(title: cameraError.titleString, message: cameraError.messageString)
            return
        }
        if addViewModel.coordinateTrigger.value != nil {
            addViewModel.urlSuccessOutPut.value?.memoImage = pickImage
        } else {
            addViewModel.modifyEnd?.markerImage = pickImage
            addViewModel.modifyEnd?.modiFy = true
            homeView.AddTitleDateView.imageView.image = pickImage
        }
        
    }
}

// MARK: PHP 피커
extension AddLocationMemoViewController {
    func checkUserPhotoAuthorization() {
        var configurataion = PHPickerConfiguration()
        configurataion.selectionLimit = 1
        configurataion.filter = .any(of: [.images])
        let phpPicker = PHPickerViewController(configuration: configurataion)
        phpPicker.delegate = self
        present(phpPicker, animated: true)
    }
}

extension AddLocationMemoViewController: PHPickerViewControllerDelegate {
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
                if self?.addViewModel.coordinateTrigger.value != nil {
                    var value = self?.addViewModel.urlSuccessOutPut.value
                    value?.memoImage = image
                    self?.addViewModel.urlSuccessOutPut.value = value
                } else {
                    self?.addViewModel.modifyEnd?.markerImage = image//.resizeImage(newWidth: 100)
                    self?.homeView.AddTitleDateView.imageView.image = image
                    self?.addViewModel.modifyEnd?.modiFy = true
                }
                
            }
        }
    }
}

