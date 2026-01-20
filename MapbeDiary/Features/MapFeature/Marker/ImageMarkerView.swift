//
//  ImageMarkerView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/20/26.
//

import UIKit
import MapKit
import Kingfisher

final class ImageMarkerView: MKAnnotationView {
    
    private enum Layout {
        static let bubbleSize = CGSize(width: 56, height: 56)
        static let tailSize = CGSize(width: 18, height: 12)
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 2
    }
    
    private let shadowView = UIView()
    private let imageView = UIImageView()
    private let outlineLayer = CAShapeLayer()
    
    private static let markerSize = CGSize(
        width: Layout.bubbleSize.width,
        height: Layout.bubbleSize.height + Layout.tailSize.height
    )
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let custom = newValue as? CustomAnnotation else { return }
            configure(for: custom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
}

extension ImageMarkerView {
    
    private func setupView() {
        canShowCallout = true
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        
        outlineLayer.fillColor = UIColor.clear.cgColor
        outlineLayer.strokeColor = UIColor.white.withAlphaComponent(0.9).cgColor
        outlineLayer.lineWidth = Layout.borderWidth
        
        addSubview(shadowView)
        shadowView.addSubview(imageView)
        shadowView.layer.addSublayer(outlineLayer)
    }
    
    private func configure(for annotation: CustomAnnotation) {
        bounds = CGRect(origin: .zero, size: Self.markerSize)
        centerOffset = CGPoint(x: 0, y: -Self.markerSize.height / 2)
        calloutOffset = CGPoint(x: 0, y: 6)
        clusteringIdentifier = "clllasdllasdl"
        
        if let memoId = annotation.locationId,
           let imageURL = FileManagers.shard.loadImageMarkerImageUrl(memoId: memoId) {
            imageView.kf.setImage(
                with: imageURL,
                placeholder: ImageSection.defaultMarkerImage.image
            )
        } else {
            imageView.image = ImageSection.defaultMarkerImage.image
                .resizeImage(maxDimension: Layout.bubbleSize.width)
        }
        
        setNeedsLayout()
    }
    
    private func performLayout() {
        shadowView.frame = bounds
        imageView.frame = bounds
        
        let path = balloonPath(in: bounds)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        imageView.layer.mask = maskLayer
        
        shadowView.layer.shadowPath = path.cgPath
        outlineLayer.frame = bounds
        outlineLayer.path = path.cgPath
    }
    
    private func balloonPath(in rect: CGRect) -> UIBezierPath {
        let bubbleHeight = rect.height - Layout.tailSize.height
        let bubbleRect = CGRect(x: 0, y: 0, width: rect.width, height: bubbleHeight)
        let path = UIBezierPath(roundedRect: bubbleRect, cornerRadius: Layout.cornerRadius)
        
        let tailHalfWidth = Layout.tailSize.width / 2
        let tailStart = CGPoint(x: rect.midX - tailHalfWidth, y: bubbleRect.maxY)
        let tailTip = CGPoint(x: rect.midX, y: rect.maxY)
        let tailEnd = CGPoint(x: rect.midX + tailHalfWidth, y: bubbleRect.maxY)
        
        let tailPath = UIBezierPath()
        tailPath.move(to: tailStart)
        tailPath.addLine(to: tailTip)
        tailPath.addLine(to: tailEnd)
        tailPath.close()
        path.append(tailPath)
        
        return path
    }
}
