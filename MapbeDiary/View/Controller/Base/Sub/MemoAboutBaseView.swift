//
//  MemoAboutBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

class MemoAboutBaseView: BaseView {
    let locationtitleLabel = UILabel()
    let locationMemoLabel = UILabel()
    let regDate = UILabel()
    let phoneNumberLabel = UILabel()
    private let phoneImage = UIImageView()
    
    private let line = UIView()
    
    override func configureHierarchy() {
        addSubview(locationtitleLabel)
        addSubview(locationMemoLabel)
        addSubview(regDate)
        addSubview(phoneNumberLabel)
        addSubview(phoneImage)
        addSubview(line)
    }
    override func configureLayout() {
        locationtitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
        }
        locationMemoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(locationtitleLabel.snp.bottom).offset(10)
        }
        regDate.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(12)
            make.top.equalTo(locationMemoLabel.snp.bottom).offset(8)
        }
        phoneNumberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(regDate.snp.bottom).offset(4)
        }
        phoneImage.snp.makeConstraints { make in
            make.trailing.equalTo(phoneNumberLabel.snp.leading).inset( -4 )
            make.size.equalTo(20)
            make.centerY.equalTo(phoneNumberLabel)
        }
        line.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.top.equalTo(phoneNumberLabel.snp.bottom).offset(10)
            make.height.equalTo(1)
        }
    }
    
    override func designView() {
        regDate.textAlignment = .right
        phoneNumberLabel.textAlignment = .right
        locationtitleLabel.font = JHFont.UIKit.bo20
        
        regDate.font = JHFont.UIKit.li11
        phoneNumberLabel.font = JHFont.UIKit.bo12
        phoneImage.image = UIImage(systemName: "phone.fill")
        
        line.backgroundColor = .systemGray
        dummy()
    }
    
    func dummy(){
        locationtitleLabel.text = "sadasd"
        phoneNumberLabel.text = "asdsadas"
        regDate.text = "asdasda"
        phoneNumberLabel.text = "sadasdsa"
        
    }
}
