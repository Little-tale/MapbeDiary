//
//  OnlyImageCollectionViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/15/24.
//

import UIKit
import SnapKit

class ImageChashe {
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

class OnlyImageCollectionViewCell: BaseCollectionViewCell {
    
    let backgoundImage = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(backgoundImage)
    }
    override func configureLayout() {
        backgoundImage.snp.makeConstraints { make in
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
        backgoundImage.image = nil
    }
    
    func settingImageMode(_ mode: ContentMode){
        self.backgoundImage.contentMode = mode
    }
    
    func loadImage(fromPath path: String,_ folder: String? = nil) {
        if let cachedImage = ImageChashe.shared.image(forKey: path){
            backgoundImage.image = cachedImage
        }
        if let folder {
            let imageData = FileManagers.shard.findDetailImageData(detailID: folder, imageIds: [path])
            switch imageData {
            case .success(let success):
                backgoundImage.image = UIImage(data: success[0])
            case .failure:
                break
            }
        }
    }
}
