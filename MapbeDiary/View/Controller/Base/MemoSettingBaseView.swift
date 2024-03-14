//
//  MemoSettingBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

final class MemoSettingBaseView: BaseView {
    
    private let titleLabel: UILabel = {
       let view = UILabel()
        view.text = "장소의 기억"
        view.font = JHFont.UIKit.bo24
        return view
    }()
    
    let memoTextView = MemoTextview()
    
    let memoTextCountLabel = UILabel()
    
    let imageCounterLabel = UILabel()
    
    let addImageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let view = UIButton(frame: .zero)
        configuration.title = "이미지 추가"
        view.configuration = configuration
        return view
    }()
    
    let colletionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.configureMemoImagesLayout())
    
    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(memoTextView)
        
        addSubview(memoTextCountLabel)
        
        addSubview(imageCounterLabel)
        addSubview(addImageButton)
        addSubview(colletionView)
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
        }
        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.equalTo(180)
        }
        
        memoTextCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(memoTextView).inset( 4 )
            make.trailing.equalTo(memoTextView).inset( 4 )
        }
        
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(8)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        
        imageCounterLabel.snp.makeConstraints { make in
            make.trailing.equalTo(addImageButton.snp.leading).inset( -8 )
            make.centerY.equalTo(addImageButton)
        }
        
        colletionView.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func designView() {
        memoTextView.font = JHFont.UIKit.li20
       //  colletionView
    }
    
    private func settingCountLabel(_ num: Int) {
        memoTextCountLabel.text = String(num) + " / 120"
    }
    
    override func subscribe() {
        memoTextView.memoTextViewModel.MaxCount = 119
        memoTextView.memoTextViewModel.currentTextCountOutPut.bind { [weak self] num in
            guard let self else { return }
            settingCountLabel(num)
        }
        memoTextView.memoTextViewModel.maxLines = 4
    }
}


