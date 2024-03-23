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
    case maximer(Int) // 여러장이지만 최대정하기
}
enum ImageSearviceError: Error {
    case cantGetImage
}

/// 이미지 관련된 기능을 제공하는 서비스 클래스 입니다.
final class ImageService: NSObject {
    typealias ImageResult = ( Result<[UIImage]?, ImageSearviceError> ) -> Void
    
    /// 이미지 피커를 띄울 뷰컨을 정의해주세요
    private weak var presntationViewController: UIViewController?
    /// 해당 핸들러를 통해 이미지들을 반환해드립니다.
    private var complitionHandler: ( ( Result<[UIImage]?, ImageSearviceError> ) -> Void )?
    /// 이미지 모드를 정할수 있습니다. 비선택 일시 Single로 합니다.
    private var pickerMode: ImagePickMode = .camera
    
    /// 피커를 띄울 부컨과 픽 모드를 선택합니다.
    init(presntationViewController: UIViewController? = nil, pickerMode: ImagePickMode) {
        self.presntationViewController = presntationViewController
        self.pickerMode = pickerMode
    }
    
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
    
    // MARK: 단일이미지 선택
    private func presentUIImagePickerController() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        DispatchQueue.main.async {
            [weak self] in
            self?.presntationViewController?.present(imagePicker, animated: true)
        }
    }
    
    private func presentPHPickerViewController(max: Int) {
        var config = PHPickerConfiguration()
        config.selectionLimit = max
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presntationViewController?.present(picker, animated: true)
    } 
    
    // MARK: 카메라 권한 확인
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

}

// MARK: 딜리게이트 채택
extension ImageService: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let imageProviders = results.map { $0.itemProvider }
        
        var images: [UIImage] = []
        
        let group = DispatchGroup()
        
        imageProviders.forEach { imagePro in
            if imagePro.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                imagePro.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    guard let self else { return }
                    
                    defer { group.leave() }
                    
                    guard let image = image as? UIImage else {
                        complitionHandler?(.failure(.cantGetImage))
                        return
                    }
                    
                    images.append(image)
                }
            }
            
        }
        
        group.notify(queue: .main){
            [weak self] in
            guard let self else { return }
            complitionHandler?(.success(images))
        }
    }
    
}

extension ImageService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            complitionHandler?(.failure(.cantGetImage))
            return
        }
        complitionHandler?(.success([image]))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        complitionHandler?(.success(nil))
    }
}


/*
 let itemProviders = results.map { $0.itemProvider }
 
 var pickedImages = [UIImage]()
 
 let group = DispatchGroup()
 
 for itemProvider in itemProviders{
     if itemProvider.canLoadObject(ofClass: UIImage.self) {
         group.enter()
         itemProvider.loadObject(ofClass: UIImage.self) { image, error in
             defer { group.leave() }
             if let image = image as? UIImage {
                 pickedImages.append(image)
             }
         }
     }
 }
 */
