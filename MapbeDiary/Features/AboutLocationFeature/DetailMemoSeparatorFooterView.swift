//
//  DetailMemoSeparatorFooterView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import UIKit
import SnapKit

final class DetailMemoSeparatorFooterView: BaseCollectionReusableView {
    
    private let separatorView = UIView()
    
    override func setupHierarchy() {
        addSubview(separatorView)
    }
    
    override func setupConstraints() {
        separatorView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    override func setupUI() {
        separatorView.backgroundColor = .systemGray4
    }
}
