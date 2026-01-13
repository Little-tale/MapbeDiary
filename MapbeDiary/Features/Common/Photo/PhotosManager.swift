//
//  PhotosManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import UIKit
import PhotosUI
import AVFoundation

enum PhotosManagerError: Error {
    case cantGetImage
    case busy
}

@MainActor
final class PhotosManager: NSObject {
    
    private var continuation: CheckedContinuation<[UIImage]?, Error>?
    
    func pickFromCamera(
        presenter: UIViewController,
        allowsEditing: Bool = true
    ) async throws -> [UIImage]? {
        if continuation != nil {
            throw PhotosManagerError.busy
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = allowsEditing
            presenter.present(picker, animated: true)
        }
    }
    
    func pickFromLibrary(
        presenter: UIViewController,
        maxSelection: Int
    ) async throws -> [UIImage]? {
        if continuation != nil {
            throw PhotosManagerError.busy
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            var config = PHPickerConfiguration()
            config.selectionLimit = maxSelection
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            presenter.present(picker, animated: true)
        }
    }
    
    func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .restricted, .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }
    
    private func finish(_ result: Result<[UIImage]?, PhotosManagerError>) {
        guard let continuation else { return }
        self.continuation = nil
        switch result {
        case let .success(images):
            continuation.resume(returning: images)
        case let .failure(error):
            continuation.resume(throwing: error)
        }
    }
    
    deinit {
        print("deinit: PhotosManager")
    }
}

// MARK: Delegates
extension PhotosManager: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            finish(.success(nil))
            return
        }
        
        Task {
            do {
                let images = try await loadImages(results: results)
                finish(.success(images))
            } catch {
                finish(.failure(.cantGetImage))
            }
        }
    }
}

extension PhotosManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage {
            finish(.success([image]))
            return
        }
        
        if let image = info[.originalImage] as? UIImage {
            finish(.success([image]))
            return
        }
        
        finish(.failure(.cantGetImage))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        finish(.success(nil))
    }
}

// MARK: Helpers
extension PhotosManager {
    private func loadImages(
        results: [PHPickerResult]
    ) async throws -> [UIImage] {
        
        let providers = results.map { $0.itemProvider }
        
        return try await withThrowingTaskGroup(
            of: UIImage?.self
        ) { group in
            for provider in providers where provider.canLoadObject(ofClass: UIImage.self) {
                group.addTask {
                    let object = try await provider.loadTask(ofClass: UIImage.self)
                    return object as? UIImage
                }
            }
            
            var images: [UIImage] = []
            
            for try await image in group {
                if let image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
}

fileprivate extension NSItemProvider {
    
    func loadTask(ofClass objectClass: NSItemProviderReading.Type) async throws -> NSItemProviderReading? {
        return try await withCheckedThrowingContinuation { continuation in
            self.loadObject(ofClass: objectClass) { object, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: object)
                }
            }
        }
    }
}

