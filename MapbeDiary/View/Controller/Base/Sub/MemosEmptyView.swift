//
//  MemosEmptyView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

class MemosEmptyView: BaseView {
    let emptyLabel = UILabel()
    let emptyButton = UIButton()
    
    override func configureHierarchy() {
        addSubview(emptyLabel)
        addSubview(emptyButton)
    }
    
    override func configureLayout() {
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
        }
        
        emptyButton.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(8)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func designView() {
        emptyLabel.numberOfLines = 2
        emptyLabel.text = MapTextSection.emptyLabelText
        emptyLabel.textAlignment = .center
        emptyLabel.font = JHFont.UIKit.me17
        emptyLabel.textColor = .wheetBlack
        emptyButton.setImage(.detailEmpty, for: .normal)
    }
}
