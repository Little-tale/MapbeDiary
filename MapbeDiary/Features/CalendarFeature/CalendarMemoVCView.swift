//
//  CalendarMemoVCView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/16/26.
//

import UIKit
import SnapKit
import FSCalendar


final class CalendarMemoVCView: VCBaseView {
    
    private var minCalendarHeight: CGFloat = 150
    private var maxCalendarHeight: CGFloat = 350
    private let snapThreshold: CGFloat = 30
    private var calendarHeightConstraint: Constraint?
    private var currentCalendarHeight: CGFloat = 400
    
    let backButton = UIButton().after {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName:"chevron.backward")
        config.baseForegroundColor = .black
        $0.configuration = config
    }
    
    let topTitleLabel = UILabel().after {
        $0.text = "날짜로 찾아보기"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    let calendarView = FSCalendar(frame: .zero)
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .init()
    )
    
    let emptyImageView: UIImageView = UIImageView().after {
        $0.image = UIImage(named: "emptyFolder")
    }
    
    override func setupHierarchy() {
        addSubview(backButton)
        addSubview(topTitleLabel)
        addSubview(calendarView)
        addSubview(collectionView)
        addSubview(emptyImageView)
    }
    
    override func setupConstraints() {
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalTo(topTitleLabel)
            make.size.equalTo(40)
        }
        
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(45)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(16)
            calendarHeightConstraint = make.height.equalTo(maxCalendarHeight).constraint
        }
        
        currentCalendarHeight = maxCalendarHeight
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(calendarView.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyImageView.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(50)
            make.height.equalTo(emptyImageView.snp.width)
        }
    }
    
    override func setupUI() {
        collectionView.setCollectionViewLayout(
            CollectionViewLayouts.createCalendarBottomCollectionViewLayout(),
            animated: false
        )
        
        calendarSetting()
    }
    
    override func register() {
        setCalendarDrag()
    }
}

extension CalendarMemoVCView {
    
    
    
    private func calendarSetting(){
        calendarView.locale = Locale.current
        
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
        
        calendarView.appearance.weekdayFont = .systemFont(ofSize: 14, weight: .semibold)
        calendarView.appearance.weekdayTextColor = .systemPink
        calendarView.appearance.headerTitleFont = .systemFont(ofSize: 18, weight: .semibold)
        calendarView.appearance.headerTitleColor = .systemPink
        
        calendarView.appearance.headerDateFormat = "yyyy.MM"
        calendarView.appearance.headerTitleAlignment = .center
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
         
        calendarView.headerHeight = 45
        
        calendarView.appearance.eventDefaultColor = .green
        calendarView.appearance.eventSelectionColor = .cyan
        
        calendarView.allowsMultipleSelection = false
        calendarView.placeholderType = .none
    }
    
    private func setCalendarDrag() {
        let action = UIPanGestureRecognizer(
            target: self,
            action: #selector(panGestureHandler)
        )
        
        calendarView.addGestureRecognizer(action)
    }
    
    
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            let translation = sender.translation(in: self)
            
            gestureTranslation(translation: translation)
            
            sender.setTranslation(.zero, in: self)
        
        case .ended:
            
            gestureEndAnimate()
            
        default: return
        }
    }
    
    private func gestureTranslation(translation: CGPoint) {
        let proposed = currentCalendarHeight + translation.y
        let clamped = max(minCalendarHeight, min(maxCalendarHeight, proposed))
        
        calendarHeightConstraint?.update(offset: clamped)
        currentCalendarHeight = clamped
    }
    
    private func gestureEndAnimate() {
        let midpoint = (minCalendarHeight + maxCalendarHeight) / 2
        
        let target: CGFloat
        let isMin: Bool
        
        if currentCalendarHeight < (midpoint - snapThreshold) {
            target = minCalendarHeight
            isMin = true
            
        } else if currentCalendarHeight > (midpoint + snapThreshold) {
            target = maxCalendarHeight
            isMin = false
            
        } else {
            let trigger = (currentCalendarHeight < midpoint)
            target = trigger ? minCalendarHeight : maxCalendarHeight
            isMin = trigger
        }
        
        calendarHeightConstraint?.update(offset: target)
        currentCalendarHeight = target
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.calendarOpenCloseAnimate(isMin: isMin)
        })
    }
    
    // MARK: Cus calendarView Animation ISSUE
    private func calendarOpenCloseAnimate(isMin: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0.15) { [weak self] in
            self?.calendarView.setScope(isMin ? .week : .month, animated: false)
            self?.calendarView.collectionView.layoutIfNeeded()
            self?.calendarView.collectionView.reloadData()
        }
    }
}
