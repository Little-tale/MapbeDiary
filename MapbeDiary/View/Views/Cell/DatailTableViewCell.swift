//
//  DetailTableViewCell.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/16/24.
//

import UIKit
import SnapKit

final class DatailTableViewCell: BaseTableViewCell {
    let detailContents = UILabel()
    let infoButton = UIButton(type: .system)
    let regDateLabel = UILabel()
    let detailcollectionView = UICollectionView(frame: .zero,collectionViewLayout: configureCellLayout())
    
    var menuModifyAction: (() -> Void)?
    var menuDeleteAction: (() -> Void)?
    
    override func configureHierarchy() {
        contentView.addSubview(detailContents)
        contentView.addSubview(infoButton)
        contentView.addSubview(regDateLabel)
        contentView.addSubview(detailcollectionView)
    }
    /*
     make.bottom.equalTo(detailcollectionView.snp.top).inset( -8 )
     make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
     */
    
    override func configureLayout() {
        regDateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(10)
        }
        
        infoButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(12)
            make.centerY.equalTo(regDateLabel)
            make.height.equalTo(28)
        }
        
        detailContents.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.top.equalTo(regDateLabel.snp.bottom).offset(10)
            make.height.greaterThanOrEqualTo(150).priority(.low)
        }
       
        detailcollectionView.snp.makeConstraints {  make in
            make.top.equalTo(detailContents.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(0)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    
    
    func imageBool(_ imageFlag: Bool){
        if imageFlag {
            detailcollectionView.isHidden = false
            detailcollectionView.snp.updateConstraints { make in
                make.height.equalTo(240)
            }
        } else {
            detailcollectionView.isHidden = true
            detailcollectionView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
    
    override func designView() {
        settingButton()
        detailContents.numberOfLines = 4
        detailContents.font = JHFont.UIKit.bo20
        regDateLabel.font = JHFont.UIKit.li17
        regDateLabel.textAlignment = .right
        
        contentView.backgroundColor = .wheetSide
        detailcollectionView.backgroundColor = .wheetSide
    }
    
    override func registers() {
        detailcollectionView.register(OnlyImageCollectionViewCell.self, forCellWithReuseIdentifier: OnlyImageCollectionViewCell.reusebleIdentifier)
    }
    
    private func settingButton(){
        infoButton.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
        
        infoButton.showsMenuAsPrimaryAction = true
        infoButton.tintColor = .systemGreen
        
        infoButton.menu = UIMenu(children: [
            UIAction(title: "Alert_modify_title".localized, handler: { [weak self] _ in
                guard let self else { return }
                menuModifyAction?()
            }),
            UIAction(title: "Alert_delete".localized, handler: { [weak self] _ in
                guard let self else { return }
                menuDeleteAction?()
            })
        ])
    }
}

// MARK: UIScreen 대채해서 하기
extension DatailTableViewCell {
    static func configureCellLayout() -> UICollectionViewFlowLayout {
        let layout = CenterFlowLayout()
        if let size = UIScreen.current?.bounds.size {
            print("Alert_success_title".localized)
            layout.itemSize = CGSize(width: size.width - 40, height: 200)
        } else {
            print("Alert_fail_title".localized)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40 , height: 200)
        }
        layout.scrollDirection = .horizontal
        return layout
    }
}

//UI Screen.main.bound 대체
extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

