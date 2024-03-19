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
        
        var imageAsset: UIImage {
            switch self {
            case .location:
                return .userLocation
            case .AllMemo:
                return .memoAsset
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
        
        layer.cornerRadius = 30
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        switch imageType {
        case .location:
            setImage(imageType.imageAsset.resizeImage(newWidth: 50), for: .normal)
        case .AllMemo:
            setImage(imageType.imageAsset.resizeImage(newWidth: 36) , for: .normal)
        }
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
}
