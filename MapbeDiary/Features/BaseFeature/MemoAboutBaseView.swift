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
    let modiFyLocationButton = UIButton()
    let phoneNumberLabel = UILabel()
    private let phoneImage = UIImageView()
    
    private let line = UIView()
    
    let memoAboutViewModel = LocationMemosViewModel()
    
    override func configureHierarchy() {
        addSubview(locationtitleLabel)
        addSubview(modiFyLocationButton)
        addSubview(locationMemoLabel)
        addSubview(regDate)
        addSubview(phoneNumberLabel)
        addSubview(phoneImage)
        addSubview(line)
    }
   
    override func configureLayout() {
        locationtitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(90)
            make.leading.equalTo(safeAreaLayoutGuide).offset(14)
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
        }
        
        locationMemoLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationtitleLabel)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(100)
            make.top.equalTo(locationtitleLabel.snp.bottom).offset(10)
        }
        modiFyLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(phoneNumberLabel.snp.top).offset( -4 )
            make.size.equalTo(30)
            make.trailing.equalTo(regDate)
        }
        phoneImage.snp.makeConstraints { make in
            make.trailing.equalTo(phoneNumberLabel.snp.leading).inset( -4 )
            make.size.equalTo(20)
            make.centerY.equalTo(phoneNumberLabel)
        }
        phoneNumberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(regDate).inset(8)
            make.bottom.equalTo(regDate.snp.top).offset( -6 )
        }
        regDate.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(12)
            make.bottom.equalTo(line.snp.top).inset( -8 )
        }
        line.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(1)
        }
    }
    
    override func designView() {
        regDate.textAlignment = .right
        phoneNumberLabel.textAlignment = .right
        locationtitleLabel.font = JHFont.UIKit.bo24
        locationtitleLabel.numberOfLines = 2
        locationMemoLabel.numberOfLines = 3
        regDate.font = JHFont.UIKit.me17
        phoneNumberLabel.font = JHFont.UIKit.bo15
        phoneImage.image = UIImage(systemName: "phone.fill")
        
        line.backgroundColor = .wheetPink
        
        
    }
  
    override func subscribe() {
        memoAboutViewModel.infoOuput.bind { [weak self] location in
            guard let self else { return }
            guard let location else { return }
            locationtitleLabel.text = location.locationName
            locationMemoLabel.text = location.locationMemo
            regDate.text = location.regDate
            phoneNumberLabel.text = location.phoneNumber
            phoneImage.isHidden = location.phoneNumber?.isEmpty ?? true
        }
    }
}
