//
//  SettingReusableView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import SnapKit

struct SettingReusableViewModel {
    static let sctionHeaderElementKind = "SettingReusableViewModel"
    let title: String
}

final class SettingReusableView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHirachy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    private func configureHirachy(){
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func settingViewModel(_ viewModel: SettingReusableViewModel) {
        titleLabel.text = viewModel.title
    }
}
