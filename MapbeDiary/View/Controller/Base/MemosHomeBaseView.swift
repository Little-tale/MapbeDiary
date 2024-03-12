//
//  MemosHomeBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/11/24.
//

import UIKit
import SnapKit

class MemosHomeBaseView: BaseView {
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private let emptyImage: UIImageView = {
        let view = UIImageView(image:  UIImage(named: "emptyFolder"))
        return view
    }()
    private let emptyMent: UILabel = {
        let view = UILabel()
        let text = "어랏! 아무것도 없어요!" // 나중에 !까지만 바꾸게
        view.textColor = .systemGreen
        let attributed = NSMutableAttributedString(string: text)
        // !까지 범위
        if let markRange = text.range(of: "!"){
            let firstAndMax = text.startIndex...markRange.lowerBound
            
            let nsRange = NSRange(firstAndMax, in: text)
            
            let highlightAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                .foregroundColor: UIColor.systemGreen
            ]
            attributed.addAttributes(highlightAttributes, range: nsRange)
        }
        view.font = .systemFont(ofSize: 22,weight: .semibold)
        view.attributedText = attributed
        view.textColor = .black
        return view
    }()
    
    var allMemoViewModel = AllMemoListViewModel()
    
    var swifeAction: ((IndexPath) -> UISwipeActionsConfiguration)?
    
    override func configureHierarchy() {
        addSubview(collectionView)
        addSubview(emptyImage)
        addSubview(emptyMent)
        
    }
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
    }
    
    func emptyLauout(screen: CGFloat) {
        emptyImage.snp.makeConstraints { make in
            make.size.equalTo(screen / 2)
            make.center.equalTo(safeAreaLayoutGuide)
        }
        emptyMent.snp.makeConstraints { make in
            make.centerX.equalTo(emptyImage)
            make.bottom.equalTo(emptyImage.snp.top).inset( -18 )
        }
    }
    
    override func subscribe() {
        regisSubscribe()
    }
}

extension MemosHomeBaseView {
    func createLayout() -> UICollectionViewLayout{
        var configu = UICollectionLayoutListConfiguration(appearance: .plain)
        configu.showsSeparators = true
        
        configu.trailingSwipeActionsConfigurationProvider = {
          [weak self] indexPath in
            self?.swifeAction?(indexPath)
        }

        let layout = UICollectionViewCompositionalLayout.list(using: configu)
        
        return layout
    }
    private func regisSubscribe(){
        allMemoViewModel.outPutCountBool.bind { [weak self] bool in
            guard let self else { return }
            guard let bool else { return }
            emptyImage.isHidden = bool
            emptyMent.isHidden = bool
        }
    }
}
