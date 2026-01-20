//
//  AboutLocationVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/18/26.
//

import UIKit
import SnapKit

final class AboutLocationVCView: VCBaseView {
    
    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .black
        
        $0.configuration = config
    }
    
    let allDeleteButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.title = "Alert_delete".localized
        config.baseForegroundColor = .md(.destructive)
        $0.configuration = config
    }
    
    let memoDetailView = MemoDetailView()
    
    let memoEmptyView = MemosEmptyView()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    let detailAddButton = UIButton().after {
        var config = UIButton.Configuration.filled()
        config.image = UIImage.detailAdd.resizeImage(maxDimension: 30)
        config.baseBackgroundColor = .white
        config.cornerStyle = .large
        $0.configuration = config
        $0.clipsToBounds = true
    }
    
    private let bottomLine = UIView().after {
        $0.backgroundColor = .separator
    }
    
    
    override func setupHierarchy() {
        addSubview(backButton)
        addSubview(allDeleteButton)
        addSubview(memoDetailView)
        addSubview(bottomLine)
        addSubview(collectionView)
        addSubview(memoEmptyView)
        addSubview(detailAddButton)
    }
    
    override func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(4)
            make.height.equalTo(20)
        }
        
        allDeleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }
        
        memoDetailView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(140)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.top.equalTo(memoDetailView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(1)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(bottomLine.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        memoEmptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(memoDetailView.snp.bottom).offset(12)
            make.height.equalTo(150)
        }
        
        detailAddButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(45)
        }
    }
    
    override func setupUI() {
        self.backgroundColor = .white
    }
    
    func isEmptyView(isHidden: Bool) {
        detailAddButton.isHidden = !isHidden
        memoEmptyView.isHidden = isHidden
    }
}
