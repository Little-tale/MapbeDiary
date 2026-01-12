//
//  Extention.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import MapKit

@available(*, deprecated, renamed: "reusableIdentifier", message: "Use reusableIdentifier")
// MARK: 재사용 아이덴티 파이어
extension UIView {
    static var reusebleIdentifier: String {
        return String(describing: self)
    }
}

@available(*, deprecated, renamed: "Will_Deprecate", message: "Will Deprecate")
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

@available(*, deprecated, renamed: "Will_Deprecate", message: "Will Deprecate")
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

@available(*, deprecated, renamed: "Will_Deprecate", message: "Will Deprecate")
extension UITextField {
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}

// MARK: String -> CLLcocation
extension UIViewController {
    
    @available(*, deprecated, renamed: "willMove", message: "Not Ready This Function")
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

@available(*, deprecated, renamed: "Will_Deprecate", message: "Will Deprecate")
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


@available(*, deprecated, renamed: "Reactor")
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func trasform(_ input: Input) -> Output
}
