//
//  Extention.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit

// MARK: 알렛 확장
extension UIViewController {
    
    func showAPIErrorAlert(urlError: URLSessionManagerError){
        
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
    
    func showAPIErrorAlert(file: fileManagerError) {

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
    
    
    // 세팅으로 유도합니다.
    func goSetting(){
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        } else {
            showAlert(title: MapTextSection.requestFail.alertTitle, message: MapTextSection.requestFail.alertMessage)
        }
    }
    
    
    
}
// MARK: 다국어 확장
extension String {
    /// 다국어 키를 현재
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
// MARK: 표현식 설정 회고
extension String {
    static func testString(text: String) -> String{
        let result = text.replacingOccurrences(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9 ]", with: "", options: .regularExpression)
        return result
    }
}
// MARK: 서치바 세팅
extension UISearchBar {
    func setTextFieldBackground(color: UIColor, transparentBackground: Bool = true) {
        if transparentBackground {
            // 서치바의 전체 배경을 투명하게 설정
            self.backgroundImage = UIImage()
        }
        // 서치바 내부의 UITextField를 찾아서 배경색을 설정
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = color
        }
        
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
    
    // MARK: 이미지 리사이징
    func resizingImage(targetSize: CGSize) -> UIImage?{
        // 원하는 CGSize(width: 원하는하는 넓이, height: 원하는 높이)
        // MARK: 각각의 원사이즈의 넓이와 높이를 대치해서 나눕니다.
        // 예를 들어 100 x 150 사이즈를 50 x 50 으로 바꾼다고 가정해보죠.
        let widthScale = targetSize.width / self.size.width
        let heightScale = targetSize.height / self.size.height
        // 그럼 각각의 스케일이 0.5 & 0.333... 이 될 것이죠?
        let minAbout = min(widthScale, heightScale) // 그중의 최소를 찾는겁니다.
        //  넓이 기준인 0.333... 이  나오겠네요!
        
        // 그럼 다시 원사이즈인 100 x 150을 (100 * 0.3333 ) "" (150 * 0.3333)를 합니다.
        let scaledImageSize = CGSize(width: size.width * minAbout, height: size.height * minAbout)
        
        // 그럼 사이즈는 33.3.. x 49.95.. 가 되겠군요
        // 새로 그릴 바탕이 될 UIGraphicsImageRenderer 를 생성합니다.
        let render = UIGraphicsImageRenderer(size: scaledImageSize)
        
        // 새로 그려질 이미지는
        let scaledImage = render.image { [weak self] _ in
            guard let self else { return }
            // 위에서 계산된 크기로 그려집니다.
            draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
    // 간단히 50 x 50 으로 만들고 싶다고 생각해봅시다.
    func resizeImageTo(_ targetSize: CGSize) -> UIImage? {
        // 그래픽 이미지 렌더러( 빈바탕 그린다고 생각해 보죠) 를 생성한후
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        // 그 바탕에 원하는 크기로 그리는 방법입니다.
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // MARK: 최신 방법
    func resizeImage(newWidth: CGFloat) -> UIImage {
        // 지정할 넒이에 원래의 넓이 나누기
        guard self.size.width != newWidth else { return self }
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


extension UILabel {
    func asFont(targetString: String) {
        let fullText = text ?? ""
        // MARK:
        let attributeString = NSMutableAttributedString(string: fullText)
        // MARK: 범위 + 대소문자 구분없이
        let range = (fullText as NSString).range(of: targetString, options: .caseInsensitive)
        
        attributeString.addAttribute(.foregroundColor ,value: UIColor.wheetOrange , range: range)
        
        attributedText = attributeString
    }
}

// CollecionViewCell ANIME
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

// MARK: String -> CLLcocation
extension UIViewController {
    
    func makeCLLcocation(lon: String, lat: String) -> CLLocationCoordinate2D? {
        let dbLat = Double(lat)
        let dbLon = Double(lon)
        
        if let dbLat,
           let dbLon {
            return CLLocationCoordinate2D(latitude: dbLat, longitude: dbLon)
        } else {
            return nil
        }
    }
    
}

// MARK: Cell LayOut

extension UICollectionView {
    static func configureMemoImagesLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        let spacing : CGFloat = 10
        let cellWidth = UIScreen.main.bounds.width - (spacing * 3)

        layout.itemSize = CGSize(width: cellWidth / 3.5, height: (cellWidth) / 3.5) // 셀의 크기
        
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        layout.minimumLineSpacing = 20
        
        layout.scrollDirection = .horizontal
        return layout
    }
}

// MARK: Date
extension Date {
    func localDate() -> String {
        let timeformetter = DateFormatter()
        
        timeformetter.locale = .current
        timeformetter.timeZone = .current
        timeformetter.dateStyle = .long
        
        let someString = timeformetter.string(from: self)
        return someString
    }
}


//MARK: 노티피케이션
extension Notification.Name {
    static let didSaveActionDetailMemo = Notification.Name("SaveDetailMemo")
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


protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func trasform(_ input: Input) -> Output
}
