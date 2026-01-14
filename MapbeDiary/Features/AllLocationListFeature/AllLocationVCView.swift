//
//  AllLocationVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import UIKit
import SnapKit

final class AllLocationVCView: VCBaseView {
    
    enum SwipeActionType: Equatable {
        case delete
        case modify
    }
    
    let topTitleLabel = UILabel().after {
        $0.text = "모아보기"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    let emptyImageView = UIImageView().after {
        $0.image = UIImage(named: "emptyFolder")
        $0.isUserInteractionEnabled = false
    }
    
    private let emptyMentLabel = UILabel()
    
    var swipeAction: ((_ action: SwipeActionType, _ indexPath: IndexPath) -> Void)?
    
    override func setupHierarchy() {
        addSubview(topTitleLabel)
        addSubview(collectionView)
        addSubview(emptyImageView)
        addSubview(emptyMentLabel)
    }
    
    override func setupConstraints() {
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.horizontalEdges.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
        }
        emptyImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }
        emptyMentLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emptyImageView)
            make.bottom.equalTo(emptyImageView.snp.top).inset( -18 )
        }
    }
    
    override func setupUI() {
        setCollectionView()
        setEmptyLabel()
        hiddenEmpty(hidden: true)
    }
}

extension AllLocationVCView {
    
    func hiddenEmpty(hidden: Bool) {
        emptyImageView.isHidden = hidden
        emptyMentLabel.isHidden = hidden
    }
}


extension AllLocationVCView {
    
    private func setEmptyLabel() {
        let text = "어랏! 아무것도 없어요!"
        emptyMentLabel.text = text
        emptyMentLabel.textColor = .systemGreen
        emptyMentLabel.asTargetText(
            target: "어랏!",
            font: UIFont.systemFont(ofSize: 30, weight: .bold)
        )
        emptyMentLabel.isUserInteractionEnabled = false
    }
    
    private func setCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        
        config.trailingSwipeActionsConfigurationProvider = {
            [weak self] indexPath in
            guard let self else { return nil }
            
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: "Alert_delete".localized
            ) { [weak self] action, view, success in
                self?.swipeAction?(.delete, indexPath)
                success(true)
            }
            
            let modifyAction = UIContextualAction(
                style: .normal,
                title: "detail_modify_title".localized
            ) { [weak self] action, view, success in
                self?.swipeAction?(.modify, indexPath)
                success(true)
            }
            
            let swipeConfig = UISwipeActionsConfiguration(
                actions: [deleteAction, modifyAction]
            )
            
            return swipeConfig
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}
