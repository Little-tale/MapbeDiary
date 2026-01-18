//
//  DetailMemoHeaderView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import UIKit
import SnapKit

final class DetailMemoHeaderView: BaseCollectionReusableView {
    
    struct SetData {
        let detail: String
        let regDate: String
    }
    
    private let detailContents = UILabel()
    
    private let infoButton = UIButton(type: .system)
    
    private let regDateLabel = UILabel()

    var menuModifyAction: (() -> Void)?
    var menuDeleteAction: (() -> Void)?
        
    
    override func setupHierarchy() {
        addSubview(detailContents)
        addSubview(infoButton)
        addSubview(regDateLabel)
    }
    
    override func setupConstraints() {
        regDateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(8)
        }
        
        infoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(regDateLabel)
            make.height.equalTo(28)
        }
        
        detailContents.snp.makeConstraints { make in
            make.top.equalTo(regDateLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func setupUI() {
        infoButton.setImage(
            UIImage(systemName: "line.3.horizontal"),
            for: .normal
        )
        infoButton.showsMenuAsPrimaryAction = true
        infoButton.tintColor = .md(.tagBlue)
        
        infoButton.menu = UIMenu(children: [
            UIAction(
                title: "Alert_modify_title".localized
            ) { [weak self] _ in
                self?.menuModifyAction?()
            },
            UIAction(
                title: "Alert_delete".localized
            ) { [weak self] _ in
                self?.menuDeleteAction?()
            }
        ])
    }
    
    func setData(data: SetData) {
        self.detailContents.text = data.detail
        self.regDateLabel.text = data.regDate
    }
}
