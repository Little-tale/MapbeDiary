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
            let imageView = UIImageView(image: imageType.imageAsset)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            addSubview(imageView)
            frame = imageView.frame
            tintColor = .wheetBlack
        }
    }
    
    private func settingHomeButton(){
        layer.cornerRadius = 30
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
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
