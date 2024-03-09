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
    func showAPIErrorAlert(repo: RealmManagerError) {
        let alert = UIAlertController(title: "Error_alert_title".localized, message: repo.alertMessage, preferredStyle: .alert)
        
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

// MARK: 재사용 아이덴티 파이어
extension UIView {
    static var reusebleIdentifier: String {
        return String(describing: self)
    }
}

// MARK: 이미지 크기 리사이징
extension UIImage {
    
    // MARK: 이건 더 알아봐야함 무슨 말인지 이해가 안감
    func resizingImage(targetSize: CGSize) -> UIImage{
        let size = self.size
        // 원하는 사이즈 / 원래 사이즈
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        // 그값이 윗스가 더 크다면
        if widthRatio > heightRatio {
            // 사이즈에 0.4? 정도 되는 값으로 곱
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK: 최신 방법
    func resizeImage(newWidth: CGFloat) -> UIImage {
        // 지정할 넒이에 원래의 넓이 나누기
        let scale = newWidth / self.size.width
        // 새 높이를 현 높이의 나눈값을 곱함
        let newHeight = self.size.height * scale
        // 비율 정리
        let size = CGSize(width: newWidth, height: newHeight)
        
        let render = UIGraphicsImageRenderer(size: size)
        
        let renderImage = render.image { [weak self] context in
            guard let self else { return }
            draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}


// MARK: 텍스트 필드
extension UITextField {
    func setPlaceholderColor(_ placeholderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
}

extension UITextField {
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
