//
//  ImageChach.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/25/24.
//

import UIKit

final class ImageChashe {
    static let shared = ImageChashe()
    private init(){}
    
    private var imageChashe = NSCache<NSString,UIImage>()
    
    func image(forKey key: String ) -> UIImage? {
        return imageChashe.object(forKey: key as NSString)
    }
    func setImage(_ image: UIImage, forKey key: String) {
        imageChashe.setObject(image, forKey: key as NSString)
    }
}
