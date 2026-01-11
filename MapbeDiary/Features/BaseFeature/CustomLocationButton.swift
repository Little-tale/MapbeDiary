//
//  CustomLocationButton.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/18/24.
//

import UIKit

class CustomLocationButton: UIButton {
    
    enum ImageType {
        case location
        case AllMemo
        case setting
        case naviBackButton
        case calendarButton
        
        var imageAsset: UIImage {
            switch self {
            case .location:
                return .userLocation
            case .AllMemo:
                return .memoAsset
            case .setting:
                return UIImage(systemName: "gear.circle") ?? UIImage()
            case .naviBackButton:
                return UIImage(systemName: "arrow.uturn.backward.circle.fill") ?? UIImage()
            case .calendarButton:
                return UIImage(systemName: "calendar.circle.fill") ?? .init()
            }
        }
    }
    
    init(frame: CGRect, imageType: ImageType) {
        super.init(frame: frame)
        configu(imageType: imageType)
        addTarget(self, action: #selector(buttonActionControll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configu(imageType: ImageType){
        
        switch imageType {
        case .location:
            settingHomeButton()
            setImage(imageType.imageAsset.resizeImage(newWidth: 50), for: .normal)
        case .AllMemo:
            settingHomeButton()
            setImage(imageType.imageAsset.resizeImage(newWidth: 36) , for: .normal)
        case .setting:
            settingHomeButton()
            setBackgroundImage(imageType.imageAsset, for: .normal)
            tintColor = .wheetBlack
        case .naviBackButton:
            sttingSFImage( imageType.imageAsset,CGRect(x: 4, y: 0, width: 30, height: 30) ,.wheetBlack)
            
        case .calendarButton:
            settingHomeButton()
            sttingSFImage(
                imageType.imageAsset,
                CGRect(x: 2, y: 0, width: 47, height: 47),
                .white,
                .scaleAspectFill
            )
        }
    }
    
    private func settingHomeButton(){
        layer.cornerRadius = 30
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    private func sttingSFImage(_ image: UIImage,_ react: CGRect ,_ color: UIColor? = nil,_ mode: UIView.ContentMode? = .scaleAspectFit){
        let imageView = UIImageView(image: image)
        imageView.contentMode = mode ?? .scaleAspectFit
        imageView.frame = react
        addSubview(imageView)
        frame = imageView.frame
        tintColor = color
    }
    
    @objc
    private func buttonActionControll(){
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            [weak self] in
            guard let self else { return }
            isUserInteractionEnabled = true
        }
        
    }
    
    deinit{
        print("deinit : ",self)
    }
}
