//
//  AddMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit
import Toast


protocol BackButtonDelegate: AnyObject {
    func backButtonClicked()
}

// MARK: 수정 혹은 새로운 모델을 통합시킵니다.
struct addViewOutStruct {
    var title: String?
    var titlePlacHolder: String?
    var content: String?
    var phoneNumber: String?
    var folderimage: String?
    var regDate = Date() // 일단 대기
    var memoImage: Data?
    var memoId: String?
    var folderName: String?
    var modifyTrigger: Bool = false
}

// plceholder없으면 로컬라이제이션 잊지마 마커 이미지도 여기서 해줘야햄
final class AddLocationMemoViewController: BaseHomeViewController<AddBaseView>{
    
    var addViewModel = AddViewModel()
    
    // 이미지 서비스 클래스 선정
    var imageService: ImageService?
    
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
        let camera = ActionRouter().actions(.camera) {
            [weak self] in
            self?.checkCameraAuthorization()
        }
        let gellery = ActionRouter().actions(.gallery) {
            [weak self] in
            self?.checkGerreyAuthorization()
        }
        let cancel = ActionRouter().cancel
        
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
            var value = addViewModel.tempSaveModel
            // var modify = addViewModel.modifyEnd
            switch textfield.tag {
            case 0:
                value.title = titleTestter(textField: textfield)
                //modify.title = titleTestter(textField: textfield)
            case 1:
                value.content = textfield.text ?? ""
                //modify.content = textfield.text
            case 2:
                value.phoneNumber = textfield.text ?? ""
                //modify.phoneNumber = textfield.text
            default:
                break
            }

            addViewModel.tempSaveModel = value
        }
        addViewModel.saveButtonTrigger.value = ()
        
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
        
        addViewModel.proceccingSuccessOutPut.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            
            homeView.folderButton.configuration?.title = folderTitle()//model.folderName
            
            homeView.folderButton.configuration?.image = UIImage(named: ImageSection.defaultFolderImage.rawValue)?.resizeImage(newWidth: 20)
        
            homeView.AddTitleDateView.dateLabel.text = DateFormetters.shared.localDate(model.regDate)
            // 플레이스 홀더
            
            homeView.AddTitleDateView.titleTextField.placeholder = model.titlePlacHolder ?? MapTextSection.emptyTitleTextFieldPlaceHolder
            // print(model.titlePlacHolder)
            
            // 이미지
            checkLocationMemoImage(data: model.memoImage)
            // 타이틀
            homeView.AddTitleDateView.titleTextField.text = model.title
            // 간편메모
            homeView.AddTitleDateView.simpleMemoTextField.text = model.content
            // 전화번호
            homeView.phoneTextField.text = model.phoneNumber
            // print(homeView.AddTitleDateView.titleTextField.placeholder)
            
        }
        
        addViewModel.dismisstrigger.bind { [weak self] void in
            guard void != nil else { return }
            guard let self else { return }
            backDelegate?.backButtonClicked()
        }
       
    }
}

extension AddLocationMemoViewController {

    func backButtonClicked() {
        // ismiss(animated: true)
        backDelegate?.backButtonClicked()
    }
    
    // MARK: 업데이트 사항
    func checkFolderIamge(string: String?) -> UIImage{
        return UIImage.defaultFolder
    }
    // MARK: 업데이트 사항
    func folderTitle() -> String{
        return MapTextSection.beginningSoon
    }
    
    func checkLocationMemoImage(data: Data? ) {
        if let data {
            homeView.AddTitleDateView.imageView.image = UIImage(data: data)
        } else{
            homeView.AddTitleDateView.imageView.image = UIImage(named: ImageSection.defaultMarkerImage.rawValue)
        }
    }
}

// MARK: imagePicker
extension AddLocationMemoViewController {
    
    // 카메라 권한 확인 로직입니다.
    func checkCameraAuthorization() {
        ///  이미지 서비스의 모드를 정합니다.  case camera || case maximer(Int)
        imageService = ImageService(presntationViewController: self, pickerMode: .camera)
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
        imageService = ImageService(presntationViewController: self, pickerMode: .maximer(1))
        startImage()
    }
    
    // MARK: 이미지 로직입니다.
    private func startImage(){
        imageService?.pickImage(complite: {[weak self] result in
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
        homeView.AddTitleDateView.imageView.image = image
    }
    
    // MARK: goSetting
    func cameraSettingAlert(){
        showAlert(title: MapTextSection.camera.alertMessage, message: MapTextSection.camera.actionTitle, actionTitle: MapTextSection.camera.actionTitle) {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
}


/*
 //struct AddOrModifyModel {
 // var value = addViewModel.proceccingSuccessOutPut.value
 //value?.memoImage = image.jpegData(compressionQuality: 1)
 // addViewModel.proceccingSuccessOutPut.value = value
 //    var title: String?
 //    var content: String?
 //    var phoneNumber: String?
 //    var folderimage: String?
 //    var regDate: Date?
 //    var markerImage: UIImage?
 //    var folder: Folder?
 //    var location: LocationMemo?
 //    var locationMemoId: String?
 //    var modiFy = false
 //
 //    init(memo: LocationMemo? = nil, folder:Folder? = nil) {
 //        self.title = memo.title
 //        self.content = memo.contents
 //        self.phoneNumber = memo.phoneNumber
 //        self.regDate = memo.regdate
 //        self.folder = folder
 //        self.locationMemoId = memo.id.stringValue
 //
 //        if let iamgePath = FileManagers.shard.loadImageMarkerImage(memoId: memo.id.stringValue) {
 //            markerImage = UIImage(contentsOfFile: iamgePath)
 //        }
 //
 //    }
 //}

 */

// MARK: 업데이트 사항
// sussesModel.folder.folderName

//            homeView.folderButton.configuration?.image = UIImage(named: sussesModel.folderimage)?.resizeImage(newWidth: 20)

//

/* // MARK:  폴더이미지도 업데이트 사헝
 if let folderImagePath = FileManagers.shard.findFolderImage(folderId: model.folder.id.stringValue) {
     
     homeView.folderButton.configuration?.image = UIImage(contentsOfFile: folderImagePath)?.resizeImage(newWidth: 20)
 } else {
 */

/*
 addViewModel.proceccingSuccessOutPut.bind { [weak self] sussesModel in
     guard let self else {return}
     guard let sussesModel else {return}
     homeView.AddTitleDateView.titleTextField.placeholder = sussesModel.titlePlacHolder
     
     homeView.folderButton.configuration?.title = MapTextSection.beginningSoon

     
     homeView.folderButton.configuration?.image = checkFolderIamge(string: sussesModel.folderimage).resizeImage(newWidth: 20)
     
     homeView.AddTitleDateView.dateLabel.text = DateFormetters.shared.localDate(sussesModel.regDate)
     
     if let image = sussesModel.memoImage {
         homeView.AddTitleDateView.imageView.image = UIImage(data: image)
     }
 }
 */
/*
 //        if addViewModel.coordinateTrigger.value != nil {
 //            var value = addViewModel.proceccingSuccessOutPut.value
 //            value?.memoImage = image.jpegData(compressionQuality: 1)
 //            addViewModel.proceccingSuccessOutPut.value = value
 //        } else {
 //            addViewModel.modifyEnd?.markerImage = image //.resizeImage(newWidth: 100)
 //            homeView.AddTitleDateView.imageView.image = image
 //            addViewModel.modifyEnd?.modiFy = true
 //        }
         
 */
/*
 //            if addViewModel.urlSuccessOutPut.value != nil {
 //                addViewModel.urlSuccessOutPut.value = value
 //            } else {
 //                addViewModel.modifyEnd = modify
 //            }
 */
