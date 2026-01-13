//
//  AddMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast


protocol BackButtonDelegate: AnyObject {
    func backButtonClicked()
}

// plceholder없으면 로컬라이제이션 잊지마 마커 이미지도 여기서 해줘야햄
final class AddLocationMemoViewController: ReactorBaseViewController<MemoAddReactor,MemoAddVCView>{
    
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
    
    // 이미지 서비스 클래스 선정
//    private var imageService: ImageService?
    
    private let photoManager = PhotosManager()
    
    // delegate
    weak var backDelegate: BackButtonDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(RealmRepository().printURL())
        mainView.backgroundColor = .skinSet
    }
    
    override func bind(reactor: MemoAddReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .compactMap { $0.realmError }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.networkError }
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(urlError: error)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.regDate }
            .map { DateFormetters.shared.localDate($0) }
            .bind(with: self) { owner, date in
                owner.mainView.AddTitleDateView.dateLabel.text = date
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.titlePlacHolder }
            .bind(with: self) { owner, text in
                owner.mainView.AddTitleDateView.titleTextField.placeholder = text
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.memoImage }
            .bind(with: self) { owner, data in
                owner.checkLocationMemoImage(data: data)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.title }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                owner.mainView.AddTitleDateView.titleTextField.text = text
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.content }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                owner.mainView.AddTitleDateView.simpleMemoTextField.text = text
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.phoneNumber }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                owner.mainView.phoneTextField.text = text
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dismissTrigger }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.backDelegate?.backButtonClicked()
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: MemoAddReactor) {
        mainView
            .AddTitleDateView
            .addImageWithButtonView
            .imageChangeButton
            .rx
            .tap
            .bind(with: self) { owner, _ in
                owner.showImageAskActionSheet()
            }
            .disposed(by: disposeBag)
        
        mainView.backButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.backDelegate?.backButtonClicked()
            }
            .disposed(by: disposeBag)
        
        mainView.saveButton.rx
            .tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { _ in MemoAddReactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.folderButton.rx
            .tap
            .map { _ in MemoAddReactor.Action.folderButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.AddTitleDateView.titleTextField.rx
            .text
            .compactMap { $0 }
            .map { MemoAddReactor.Action.currentTitleTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.AddTitleDateView.simpleMemoTextField.rx
            .text
            .compactMap { $0 }
            .map { MemoAddReactor.Action.currentContentTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.phoneTextField.rx
            .text
            .compactMap { $0 }
            .map { MemoAddReactor.Action.currentPhoneNumberTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func showImageAskActionSheet(){
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
        
        let galleryAction = UIAlertAction(
            title: PhotoActionType.gallery.title,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            startGallery()
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


   
    private func titleTester(textField : UITextField) -> String{
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
    
    func setModifier(memoID: String) {
        reactor?.action.onNext(.setMemoID(memoID))
    }
    
    func setKakaoData(data: PlaceDocumentEntity) {
        reactor?.action.onNext(.setKakaoData(data))
    }
    
    func setAddModel(model: AddModel) {
//        addViewModel.coordinateTrigger.value = model
        reactor?.action.onNext(.setAddModel(model))
    }
}

extension AddLocationMemoViewController {
    
    private func checkLocationMemoImage(data: Data? ) {
        if let data {
            mainView.AddTitleDateView.addImageWithButtonView.imageView.image = UIImage(data: data)
        } else{
            mainView.AddTitleDateView.addImageWithButtonView.imageView.image = UIImage(named: ImageSection.defaultMarkerImage.rawValue)
        }
    }
}

// MARK: Helpers
extension AddLocationMemoViewController {
    
    
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
                    
                    await sendImage(image)
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
    
    private func startGallery() {
        Task { @MainActor in
            do {
                let result = try await photoManager.pickFromLibrary(
                    presenter: self,
                    maxSelection: 1
                )
                guard let image = result?.first else {
                    return
                }
                
                await sendImage(image)
            } catch {
                print(error)
            }
        }
    }
    
    private func sendImage(_ image: UIImage) async {
        
        mainView.AddTitleDateView.addImageWithButtonView.imageView.image = image
        
        guard let data = await image.onlyCompressImage(
            type: .jpeg,
            targetMB: 5
        ) else {
            print("압축 실패")
            return
        }
        
        reactor?.action.onNext(.sendImage(data))
    }
    
    
    // MARK: goSetting
    private func goCameraSettingAlert(){
        showAlert(title: MapTextSection.camera.alertMessage, message: MapTextSection.camera.actionTitle, actionTitle: MapTextSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
}

//    private func saveButtonClicked(){
//        homeView.textFieldList.forEach { textfield in
//
//            var value = addViewModel.tempSaveModel
//            // var modify = addViewModel.modifyEnd
//            switch textfield.tag {
//            case 0:
//                value.title = titleTester(textField: textfield)
//                //modify.title = titleTestter(textField: textfield)
//            case 1:
//                value.content = textfield.text ?? ""
//                //modify.content = textfield.text
//            case 2:
//                value.phoneNumber = textfield.text ?? ""
//                //modify.phoneNumber = textfield.text
//            default:
//                break
//            }
//
//            addViewModel.tempSaveModel = value
//        }
//        addViewModel.saveButtonTrigger.value = ()
//
//        SingleToneDataViewModel.shared.shardFolderOb.value =  SingleToneDataViewModel.shared.shardFolderOb.value
//    }

/*
 // MARK: imagePicker
 extension AddLocationMemoViewController {
     
     // 카메라 권한 확인 로직입니다.
     private func checkCameraAuthorization() {
         ///  이미지 서비스의 모드를 정합니다.  case camera || case maximer(Int)
         imageService = ImageService(presentationViewController: self, pickerMode: .camera)
         // 이미지 서비스를 통해 권한 확인을 합니다.
         imageService?.checkCameraPermission(compltion: { [weak self] bool in
             guard let self else { return }
             if !bool {
                 cameraSettingAlert() // 권한이 거부 되었거든 설정으로 안내할 알렛
             } else {
                 startImage() // 이미지 시작!
             }
         } )
     }
     
     // 갤러리를 선택했을때 권한 확인 로직입니다.
     private func checkGerreyAuthorization(){
         imageService = ImageService(presentationViewController: self, pickerMode: .maximum(1))
         startImage()
     }
     
     // MARK: 이미지 로직입니다.
     private func startImage(){
         imageService?.pickImage(complete: {[weak self] result in
             guard let self else { return }
             switch result {
             case .success(let images):
                 let image = images?.first
                 changeImage(image)
             case .failure(let fail):
                 print(fail)
             }
         })
     }
     
     // MARK: 상황별 이미지 저장 로직
     private func changeImage(_ image: UIImage?){
         guard let image else { return }

         addViewModel.tempSaveModel.memoImage = image.jpegData(compressionQuality: 1)
         addViewModel.imageChangeTrigger = true
 //        homeView.AddTitleDateView.imageView.image = image
     }
     
    
 }
 */
