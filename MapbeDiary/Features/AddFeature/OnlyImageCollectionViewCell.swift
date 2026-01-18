//
//  OnlyImageCollectionViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit
import SnapKit

final class OnlyImageCollectionViewCell: BaseCollectionViewCell {
    
    let backgroundImage = UIImageView()
    private var currentImageKey: String?
    
    override func configureHierarchy() {
        contentView.addSubview(backgroundImage)
    }
    override func configureLayout() {
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    override func designView() {
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.backgroundColor = .black
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        currentImageKey = nil
        backgroundImage.image = nil
    }
    
    func setData(data: Data) {
        self.backgroundImage.image = UIImage(data: data)
    }
    
    func settingImageMode(_ mode: ContentMode){
        self.backgroundImage.contentMode = mode
    }
    
    func loadImage(fromPath path: String,_ folder: String? = nil) {

        if let folder {
            let imageData = FileManagers.shard.findDetailImageData(detailID: folder, imageIds: [path])
            switch imageData {
            case .success(let success):
                backgroundImage.image = UIImage(data: success[0])
            case .failure:
                break
            }
        }
    }
    
    func setImage(from url: URL, cache: NSCache<NSString, UIImage>) {
        let key = url.absoluteString as NSString
        currentImageKey = key as String
        
        if let cachedImage = cache.object(forKey: key) {
            backgroundImage.image = cachedImage
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  var image = UIImage(data: data) else {
                return
            }
            
            image = image.resizeImage(maxDimension: 300)
            
            cache.setObject(image, forKey: key)
            
            DispatchQueue.main.async {
                guard self?.currentImageKey == key as String else { return }
                self?.backgroundImage.image = image
            }
        }
    }
}


/*
 //        if let cachedImage = ImageChashe.shared.image(forKey: path){
 //            backgoundImage.image = cachedImage
 //        }
 */
