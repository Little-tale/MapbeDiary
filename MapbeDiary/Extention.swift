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
    
}
// MARK: 다국어 확장
extension String {
    /// 다국어 키를 현재
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
