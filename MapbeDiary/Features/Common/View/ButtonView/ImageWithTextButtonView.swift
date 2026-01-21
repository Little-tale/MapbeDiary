//
//  ImageWithTextButtonView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/21/26.
//

import UIKit
import SnapKit

final class ImageWithTextButtonView: BaseView {
    
    let imageView = UIImageView()
    
    let textLabel = UILabel()
    
    private let inset: UIEdgeInsets
    private let spacing: CGFloat
    
    init(
        inset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
        spacing: CGFloat = 4
    ) {
        self.inset = inset
        self.spacing = spacing
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        addSubview(imageView)
        addSubview(textLabel)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(inset.top)
            make.leading.equalToSuperview().inset(inset.left)
            make.bottom.equalToSuperview().inset(inset.bottom)
        }
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(spacing)
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(inset.right)
        }
    }
}


