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

enum ImagePickMode{
    case single // 한장만
    case maximer(Int) // 여러장
}
// MARK: 더 알아오보고 이해한후 사용해 보기
final class ImageService: NSObject {
    
    private weak var presntationViewController: UIViewController?
    
    private var complitionHandler: (([UIImage]?) -> Void)?
    
    private var pickerMode: ImagePickMode = .single
    
    init(presntationViewController: UIViewController? = nil, pickerMode: ImagePickMode) {
        self.presntationViewController = presntationViewController
        self.pickerMode = pickerMode
    }
    
    func pickImage(complite: @escaping ([UIImage]?) -> Void){
        complitionHandler = complite
        switch pickerMode {
        case .single:
            presentUIImagePickerController()
        case .maximer(let int):
            presentPHPickerViewController(max: int)
        }
    }
    // MARK: 단일이미지 선택
    private func presentUIImagePickerController() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        presntationViewController?.present(imagePicker, animated: true)
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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: // 권환확인
            compltion(false)
        case .restricted, .denied: // 거부된 상황
            AVCaptureDevice.requestAccess(for: .video) { bool in
                DispatchQueue.main.async {
                    compltion(bool)
                }
            }
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
        
        group.notify(queue: .main){
            [weak self] in
            guard let self else { return }
            complitionHandler?(pickedImages.isEmpty ? nil : pickedImages)
        }
    }
    
}

extension ImageService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        let image = info[.editedImage] as? UIImage
        complitionHandler?(image != nil ? [image!] : nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        complitionHandler?(nil)
    }
}
