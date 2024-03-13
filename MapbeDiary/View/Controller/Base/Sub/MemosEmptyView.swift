//
//  MemosEmptyView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit


class MemosEmptyView: BaseView {
    let emptyLabel = UILabel()
    let emptyButton = UIButton()
    
    override func configureHierarchy() {
        addSubview(emptyLabel)
        addSubview(emptyButton)
    }
    
    override func configureLayout() {
        emptyLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(40)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
        }
        emptyButton.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(8)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }
    }
}
