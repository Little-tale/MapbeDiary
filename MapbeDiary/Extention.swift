//
//  Extention.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import UIKit

// MARK: 알렛 확장
extension UIViewController {
    
    func showAPIErrorAlert(urlError: URLSessionManagerError){
        
        let alert = UIAlertController(title: "Error_alert_title".localized, message: urlError.errorMessage, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)

        present(alert,animated: true)
    }
    
    func showAlertHandler(title: String, message: String,actionTitle: String, handler: @escaping (UIAlertAction) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: actionTitle, style: .destructive, handler: handler)
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String,actionTitle: String, handler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Cancel_check_title" .localized, style: .destructive)
        
        let okButton = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
    
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Alert_check_title".localized, style: .destructive)
        alert.addAction(okButton)
        present(alert, animated: true )
    }
    
}
// MARK: 다국어 확장
extension String {
    /// 다국어 키를 현재
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}


extension UIView {
    static var reusebleIdentifier: String {
        return String(describing: self)
    }
}
