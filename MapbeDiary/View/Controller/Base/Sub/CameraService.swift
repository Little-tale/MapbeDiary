//
//  CameraService.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import UIKit
import PhotosUI
import AVFoundation
import Photos


/// 이미지 선택 방식 정의
enum ImagePickMode{
    case camera // 한장만 할 경우
    case maximer(Int) // 갤러리, 여러장이지만 최대정하기
}
enum ImageServiceError: Error {
    case cantGetImage
}

/// 이미지 관련된 기능을 제공하는 서비스 클래스 입니다.
final class ImageService: NSObject {
    
    // 반환할 Result 를 정의
    typealias ImageResult = ( Result<[UIImage]?, ImageServiceError> ) -> Void
    
    /// 이미지 피커를 띄울 뷰컨을 정의해주세요
    private weak var presntationViewController: UIViewController?
    
    /// 해당 핸들러를 통해 이미지들을 반환해드립니다.
    private var complitionHandler: ( ( Result<[UIImage]?, ImageServiceError> ) -> Void )?
    
    /// 이미지 모드를 정할수 있습니다. 비선택 일시 Single로 합니다.
    private var pickerMode: ImagePickMode = .camera
    
    /// 피커를 띄울 부컨과 픽 모드를 선택합니다.
    init(presntationViewController: UIViewController? = nil, pickerMode: ImagePickMode) {
        self.presntationViewController = presntationViewController
        self.pickerMode = pickerMode
    }
   
    
    // MARK: 카메라 선택시
    private func presentUIImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera // 카메라로 설정합니다.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // 편집을 허용합니다.
        DispatchQueue.main.async {
            [weak self] in
            self?.presntationViewController?.present(imagePicker, animated: true)
        }
    }
    // MARK: 갤러리 선택시
    private func presentPHPickerViewController(max: Int) {
        var config = PHPickerConfiguration()
        config.selectionLimit = max // 선택할수 있는 개수를 정합니다.
        config.filter = .images // 선택할수 있는 유형을 이미지로 제한합니다.
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        DispatchQueue.main.async {
            [weak self] in
            self?.presntationViewController?.present(picker, animated: true)
        }
    }
    
    /// 이미지를 가져와 드립니다. 그과정에서 어떤 (imagePick or PHPicker ) 는 여기서 해결합니다.
    func pickImage(complite: @escaping ImageResult){
        print("이미지 서비스의 사진 겟또가 시작되었습니다. ")
        complitionHandler = complite
        switch pickerMode {
        case .camera:
            presentUIImagePickerController()
        case .maximer(let int):
            presentPHPickerViewController(max: int)
        }
    }
    
    // MARK: 카메라 권한 확인
    /// 이미지 권한을 요청하시면 결론을 내어 드려요.
    func checkCameraPermission(compltion: @escaping (Bool) -> Void) {
        print("이미지 서비스의 카메라 권한 확인 서비스가 시작되었습니다. ")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: // 권환확인 한번도 안함
            AVCaptureDevice.requestAccess(for: .video) { bool in
                DispatchQueue.main.async {
                    compltion(bool)
                }
            }
        case .restricted, .denied: // 거부된 상황
            compltion(false)
        case .authorized: // 허용
            compltion(true)
        @unknown default: // 모르는 상황
            compltion(false)
        }
    }
    
    deinit {
        print("ImageService : SUCCESS DEINIT")
    }
}

// MARK: 딜리게이트 채택
extension ImageService: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 선택이 감지되면 내립니다.
        picker.dismiss(animated: true)
        // 결과를 아이템 프로바이더 -> PhotosUI_PHPickerResult(구조체)_프로퍼티
        let imageProviders = results.map { $0.itemProvider }
        
        // 이미지들을 담을 빈 배열선언
        var images: [UIImage] = []
        // 이미지를 load할때 비동기적으로 함으로 동시에 반영하기 위한 그룹
        let group = DispatchGroup()
        // 반복문을 시도합니다.
        imageProviders.forEach { imagePro in
            // 만약 로드할 오브젝트가 UIImage 클래스라면
            if imagePro.canLoadObject(ofClass: UIImage.self) {
                // 그룹에 넣습니다.
                group.enter()
                // 이미지로 예상 되는것을 로드합니다.
                imagePro.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    // MARK: Defer: 무슨일이 있어도 실행 시킵니다.
                    defer { group.leave(); print("디퍼")}
                    // 만약 약한참조로 실패한다면 가져오지 못함을 클라이언트 에게 알립니다.
                    guard let self else {
                        self?.complitionHandler?(.failure(.cantGetImage))
                        
                        return
                    }
                    // 만약 이미지가 UIImage가 아니라면
                    guard let image = image as? UIImage else {
                        // 이미지를 가져오지 함을 알립니다.
                        complitionHandler?(.failure(.cantGetImage))
                        
                        return
                    }
                    // 빈 이미지 배열에 추가시킵니다.
                    images.append(image)
                }
            }
        }
        // 모든 그룹의 작업들이 완료가 되었다면(예약)
        group.notify(queue: .main){
            [weak self] in
            guard let self else { return }
            // 모두 작업이 완료 됬음을 즉 이미지를 넘깁니다.
            complitionHandler?(.success(images))
        }
    }
    
}

extension ImageService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 이미지 피커
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 사용자가 마무리 됨을 감지합니다.
        picker.dismiss(animated: true)
        // 만약 이미지가 아니라면
        guard let image = info[.editedImage] as? UIImage else {
            // 가져올수 없음을 클라이언트에게 알립니다.
            complitionHandler?(.failure(.cantGetImage))
            return
        }
        // 성공시
        complitionHandler?(.success([image]))
    }
    /// 이미지 피커 뒤로가기 시도시
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        complitionHandler?(.success(nil))
    }
}
