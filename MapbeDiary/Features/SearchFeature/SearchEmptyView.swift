//
//  SearchEmptyView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import UIKit
import SnapKit

class SearchEmptyView: BaseView {
    
    private let shadowContainerView = UIView().after {
        $0.backgroundColor = .clear
        $0.layer.shadowColor = UIColor.orange.withAlphaComponent(0.4).cgColor
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 50
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.borderWidth = 0
    }
    
    private let imageView = UIImageView(frame: .zero).after {
        $0.image = .searchEmptyIcon
        $0.contentMode = .scaleAspectFit
        $0.layer.borderWidth = 0
        $0.layer.cornerRadius = 40
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        $0.layer.masksToBounds = true
    }
    
    private let topTitleLabel = UILabel().after {
        $0.text = "Search_place2".localized
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().after {
        $0.text = "Search_place3".localized
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .black.withAlphaComponent(0.5)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let recommendTagTitleLabel = UILabel().after {
        $0.textColor = .black.withAlphaComponent(0.5)
        $0.text = "Search_tag_title".localized
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let wrappedTagView = WrappedTagView().after {
        $0.setTags([
            "성수동 카페",
            "한남동 맛집",
            "강남역 식당"
        ])
    }
    
    override func configureHierarchy() {
        addSubview(shadowContainerView)
        shadowContainerView.addSubview(imageView)
        addSubview(topTitleLabel)
        addSubview(subTitleLabel)
        addSubview(recommendTagTitleLabel)
        addSubview(wrappedTagView)
    }
    
    override func configureLayout() {
        shadowContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(14)
        }
        
        recommendTagTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().inset(12)
        }
    
        wrappedTagView.snp.makeConstraints { make in
            make.top.equalTo(recommendTagTitleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(roundedRect: shadowContainerView.bounds, cornerRadius: 40)
        shadowContainerView.layer.shadowPath = shadowPath.cgPath
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    SearchEmptyView()
}
#endif
