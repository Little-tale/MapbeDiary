//
//  DefaultMarkerView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/20/26.
//

import UIKit
import MapKit

final class DefaultMarkerView: MKAnnotationView {
    
    private enum Layout {
        static let imageSize: CGFloat = 45
    }
    
    private let imageView = UIImageView()
    
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
            configure()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

extension DefaultMarkerView {
    
    private func setupView() {
        canShowCallout = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        addSubview(imageView)
    }
    
    private func configure() {
        let size = CGSize(width: Layout.imageSize, height: Layout.imageSize)
        bounds = CGRect(origin: .zero, size: size)
        centerOffset = CGPoint(x: 0, y: -Layout.imageSize / 2)
        calloutOffset = CGPoint(x: 0, y: 4)
        clusteringIdentifier = "clllasdllasdl"
        
        imageView.image = ImageSection.defaultMarkerImage.image
            .resizeImage(maxDimension: Layout.imageSize)
        
        setNeedsLayout()
    }
}
