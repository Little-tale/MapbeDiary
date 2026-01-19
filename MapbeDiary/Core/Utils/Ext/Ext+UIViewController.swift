//
//  Ext+UIViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit

extension UIViewController {
    
    /// Change Root View Controller
    /// - Parameter vc: UIViewController
    func changeRootView(_ vc: UIViewController){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let windes = windowScene.windows.first {
                UIView.transition(with: windes, duration: 0.6) {
                    windes.rootViewController = vc
                }
                windes.makeKeyAndVisible()
            }
        }
    }
}

// MARK: UIViewController + Alert
extension UIViewController {
    
    func showAPIErrorAlert(urlError: NetworkManagerError){
        
        let alert = UIAlertController(title: "Error_alert_title".localized, message: urlError.errorMessage, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            present(alert,animated: true)
        }
    }
    
    func showAPIErrorAlert(repo: RealmManagerError) {
        let alert = UIAlertController(title: "Error_alert_title".localized, message: repo.alertMessage, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            present(alert,animated: true)
        }
    }
    
    func showAPIErrorAlert(file: FileManagerError) {

        let alert = UIAlertController(title: "Error_alert_title".localized, message: file.message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            present(alert,animated: true)
        }
    }
    
    func showAlertHandler(title: String, message: String,actionTitle: String, handler: @escaping (UIAlertAction) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: actionTitle, style: .destructive, handler: handler)
        
        alert.addAction(okButton)
        DispatchQueue.main.async {
            [weak self] in guard let self else { return }
            present(alert, animated: true)
        }
    }
    
    func showAlertHandlerCancel(title: String?, message: String?, actionTitle: String?, handler: @escaping (UIAlertAction) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        let cancelButton = UIAlertAction(title: "Cancel_check_title" .localized, style: .destructive)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            [weak self] in guard let self else { return }
            present(alert, animated: true)
        }
    }
    
    func showAlert(title: String?, message: String?,actionTitle: String?, handler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Cancel_check_title" .localized, style: .destructive)
        
        let okButton = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            [weak self] in guard let self else { return }
            present(alert, animated: true)
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)
        DispatchQueue.main.async {
            [weak self] in guard let self else { return }
            present(alert, animated: true)
        }
    }
    
    
    /// 세팅으로 유도합니다.
    func goSetting(){
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        } else {
            showAlert(title: MapTextSection.requestFail.alertTitle, message: MapTextSection.requestFail.alertMessage)
        }
    }
}

// MARK: CollectionView Cell Animation
extension UIViewController {
    
    func collectionViewCellAnimation(cell: UICollectionViewCell){
        UIView.animate(withDuration: 0.08, animations: {
            cell.backgroundColor = .green // 선택됐을 때의 색
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                cell.backgroundColor = .white // 원래 색으로 돌아감
            }
        }
    }
}

// MARK: Toast
protocol ToastPro {}

extension ToastPro where Self: UIViewController {
    func showToastBody(title: String?, message: String?, completion: ((Bool) -> Void)? = nil ) {
        self.view.makeToast(message,
                            duration: 1.5,
                            point: CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2),
                            title: title,
                            image: .cantAdd) { didTap in
            completion?(didTap)
        }
    }
}
