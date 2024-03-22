//
//  MemoSettingBaseView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import UIKit
import SnapKit

final class MemoSettingBaseView: BaseView {
    
    let memoViewModel = AboutMemoViewModel()
    
    private let titleLabel: UILabel = {
       let view = UILabel()
        view.text = "Memories_of_place".localized
        view.font = JHFont.UIKit.bo24
        return view
    }()
    
    let saveButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let view = UIButton(frame: .zero)
        configuration.baseBackgroundColor = .wheetGreen
        configuration.baseForegroundColor = .wheetBlack
        configuration.title = "Add_save_button_text".localized
        view.configuration = configuration
        return view
    }()
    
    let deleteButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let view = UIButton(frame: .zero)
        configuration.baseBackgroundColor = .wheetDarkPink
        configuration.baseForegroundColor = .wheetPink
        configuration.title = "Alert_delete".localized
        view.configuration = configuration
        return view
    }()
    
    let backButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let view = UIButton(frame: .zero)
        
        configuration.image = UIImage(systemName: "chevron.backward")
        configuration.baseForegroundColor = .wheetBlack
        view.configuration = configuration
        return view
    }()
    
    let memoTextView = MemoTextview()
    
    let memoTextCountLabel = UILabel()
    
    let imageCounterLabel = UILabel()
    
    let addImageButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        let view = UIButton(frame: .zero)
        configuration.title = "Add_image_title".localized
        configuration.baseBackgroundColor = .wheetBlue
        configuration.baseForegroundColor = .wheetBlack
        view.configuration = configuration
        return view
    }()
    
    let colletionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.configureMemoImagesLayout())
    
    override func configureHierarchy() {
        addSubview(backButton)
        addSubview(saveButton)
        addSubview(deleteButton)
        addSubview(titleLabel)
        addSubview(memoTextView)
        addSubview(memoTextCountLabel)
        addSubview(imageCounterLabel)
        addSubview(addImageButton)
        addSubview(colletionView)
    }
    
    override func configureLayout() {
       
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(10)
            make.centerY.equalTo(saveButton)
        }
        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(memoTextView.snp.trailing)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            // make.centerY.equalTo(titleLabel)
            make.height.equalTo(27)
        }
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalTo(saveButton.snp.leading).inset( -4 )
            make.top.height.equalTo(saveButton)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(saveButton.snp.bottom).offset(10)
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
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(130)
        }
    }
    
    override func designView() {
        memoTextView.font = JHFont.UIKit.li20
        colletionView.backgroundColor = .wheetSideBrown
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
    
    override func register() {
        colletionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        colletionView.register(OnlyImageCollectionViewCell.self, forCellWithReuseIdentifier: OnlyImageCollectionViewCell.reusebleIdentifier)
    }
    
    func imageCounterSetting(){
        imageCounterLabel.text = "\(memoViewModel.emptyModel.value.viewImageData.count) / \(memoViewModel.maxImageCount)"
    }
}


