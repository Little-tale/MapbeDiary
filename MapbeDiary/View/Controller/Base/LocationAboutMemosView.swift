//
//  LocationAboutMemosView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

final class LocationAboutMemosView: BaseView {
    
    let backButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let view = UIButton(frame: .zero)
        configuration.image = UIImage(systemName: "chevron.backward")
        configuration.baseForegroundColor = .wheetBlack
        view.configuration = configuration
        return view
    }()
    
    let allDeleteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let view = UIButton(frame: .zero)
        configuration.title = "Alert_delete".localized
        configuration.baseForegroundColor = .red
        view.configuration = configuration
        return view
    }()
    
    
    
    let memoAboutBaseView = MemoAboutBaseView()
    let memoEmptyView = MemosEmptyView()
    
    let detailTableView = UITableView(frame: .zero)
    
    let detailAddButton = UIButton()

    override func configureHierarchy() {
        addSubview(backButton)
        addSubview(allDeleteButton)
        addSubview(memoAboutBaseView)
       
        addSubview(detailTableView)
        addSubview(memoEmptyView)
        addSubview(detailAddButton)
    }
 
    override func configureLayout() {
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.size.equalTo(20)
        }
        
        allDeleteButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(8)
            make.top.equalTo(safeAreaLayoutGuide).offset( 8 )
            make.height.equalTo(20)
        }
      
        memoAboutBaseView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset( 5 )
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(140)
        }
        
        detailTableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(memoAboutBaseView.snp.bottom)
        }
        
        memoEmptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(memoAboutBaseView.snp.bottom).offset(12)
            make.height.equalTo(150)
        }
        detailAddButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(45)
        }
    }
    
    override func designView() {
        detailButtonSetting()
        detailTableView.separatorColor = .systemGray
        detailTableView.backgroundColor = .wheetSide
        modifyLocationButtonSetting()
    }
    
    override func register() {
        tableViewDelegateDataSource()
        
        detailTableView.register(DatailTableViewCell.self, forCellReuseIdentifier: DatailTableViewCell.reusebleIdentifier)
    }
    
    func tableViewDelegateDataSource(){
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 240
        detailTableView.layer.cornerRadius = 24
        detailTableView.clipsToBounds = true 
    }
    
    private func detailButtonSetting(){
        var config = UIButton.Configuration.filled()
        config.image = UIImage.detailAdd.resizeImage(newWidth: 45)
        config.baseBackgroundColor = .white
        config.cornerStyle = .large
        detailAddButton.configuration = config
        detailAddButton.clipsToBounds = true
    }
    
    private func modifyLocationButtonSetting(){
        var configu = UIButton.Configuration.plain()
        configu.image = .annotaionModify.resizeImage(newWidth: 30)
       
        memoAboutBaseView.modiFyLocationButton.configuration = configu
    }
}


/*
 func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
     let size = image.size
     
     let widthRatio  = targetSize.width  / size.width
     let heightRatio = targetSize.height / size.height
     
     // 비율에 따라 새 크기 결정
     var newSize: CGSize
     if(widthRatio > heightRatio) {
         newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
     } else {
         newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
     }
     
     // 그래픽 컨텍스트에서 이미지를 그림
     let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
     UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
     image.draw(in: rect)
     let newImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     return newImage
 }
 */
