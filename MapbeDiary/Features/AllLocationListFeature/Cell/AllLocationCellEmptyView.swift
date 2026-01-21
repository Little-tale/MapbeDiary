//
//  AllLocationCellEmptyView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/22/26.
//

import UIKit
import SnapKit

final class AllLocationCellEmptyView: BaseView {
    
    private let backgroundView = UIView().after {
        $0.backgroundColor = .md(.tagYellow)
    }
    
    private let pinImageView = UIImageView().after {
        $0.image = .defaultMarker
    }
    
    override func configureHierarchy() {
        addSubview(backgroundView)
        backgroundView.addSubview(pinImageView)
    }
    
    override func configureLayout() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pinImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.center.equalToSuperview()
        }
    }
}
