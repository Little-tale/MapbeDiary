//
//  SettingNavigationVIew.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/21/24.
//

import UIKit
import SnapKit

//class SettingNavigationView: UIView {
//    private let imageView = UIImageView()
//    private let titleLabel = UILabel()
//    
//    func configureHierarchy() {
//        addSubview(imageView)
//        addSubview(titleLabel)
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .wheetBlack
//        configureHierarchy()
//        configureLayout()
//        designView()
//        self.backgroundColor = .black
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//  func configureLayout() {
//        imageView.snp.makeConstraints { make in
//            make.verticalEdges.equalToSuperview()
//            make.leading.equalToSuperview()
//        }
//        titleLabel.snp.makeConstraints { make in
//            make.verticalEdges.equalToSuperview()
//            make.leading.equalTo(imageView.snp.trailing)
//        }
//       
//    }
//    
//   func designView() {
//        titleLabel.text = "설정"
//        imageView.image = UIImage(systemName: "star")
//    }
//}
