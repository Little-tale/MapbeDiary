//
//  CalendarMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import FSCalendar


final class CalendarMemoViewController: ReactorBaseViewController<CalendarMemoViewReactor,CalendarMemoVCView> {
    
    enum Section: CaseIterable {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, LocationMemoEntity>
    
    typealias CellRegister = UICollectionView.CellRegistration<CalendarCollectionViewCell, LocationMemoEntity>
    
    private var dataSource: DataSource?
    
    
    var selectedLocationMemo: ((LocationMemoEntity) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationSetting()
    }
    
    override func register() {
        mainView.calendarView.delegate = self
        mainView.calendarView.dataSource = self
        setCollectionViewDataSource()
    }
    
    override func bind(reactor: CalendarMemoViewReactor) {
        super.bind(reactor: reactor)
        
        reactor.state
            .map { $0.setCalendarDate }
            .distinctUntilChanged()
            .bind(with: self) { owner, date in
                owner.setDate(date: date)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$calendarReloadTrigger)
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.mainView.calendarView.reloadData()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.locationMemos }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, models in
                owner.mainView.emptyImageView.isHidden = !models.isEmpty
                owner.snapShot(models: models)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$realmError)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, error in
                owner.showAPIErrorAlert(repo: error)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedLocationMemo)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, entity in
                owner.selectedLocationMemo?(entity)
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
    }
    
    override func sendActions(reactor: CalendarMemoViewReactor) {
        rx.viewDidLoad
            .map { _ in CalendarMemoViewReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx
            .itemSelected
            .map { CalendarMemoViewReactor.Action.selectedIndex($0.item)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.backButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
    }
    
    private func setDate(date: Date) {
        mainView.calendarView.select(date, scrollToDate: true)
    }
    
}

// MARK: CollectionView
extension CalendarMemoViewController {
    
    private func snapShot(models: [LocationMemoEntity]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, LocationMemoEntity>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(models)
        dataSource?.apply(snapShot, animatingDifferences: true)
    }
    
    private func setCollectionViewDataSource() {
        
        let cellRegister = setCollectionViewCellRegister()
        
        dataSource = DataSource(
            collectionView: mainView.collectionView
        ) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegister,
                for: indexPath,
                item: itemIdentifier
            )
        }
    }
    
    private func setCollectionViewCellRegister() -> CellRegister {
        let cellRegister = CellRegister { cell, indexPath, item in
            cell.backgroundColor = .wheetBior
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            cell.setModel(location: item)
        }
        return cellRegister
    }
}

extension CalendarMemoViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // MARK: 캘린더 선택 날짜 색상 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return .wheetBlue
    }
    // MARK: 전체 Date 비교 배경색 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if DateFormatterManager.shared.calendarCheck(Date(), compareFor: date) {
            return .systemPink
        }
        return appearance.borderDefaultColor
    }
    
    // MARK: 전체 Date 비교 배경색 지정
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if DateFormatterManager.shared.calendarCheck(Date(), compareFor: date) {
            return "today"
        }
        return nil
    }
    
    // MARK: 선택된 날짜 전달
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        reactor?.action.onNext(.selectedDate(date))
    }
    
    // MARK: 최저 날짜 선택
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        return reactor?.currentState.minimumDate ?? Date()
    }
    
    // MARK: 최대 날짜 정하기
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    // MARK: 캘린더 이벤트 갯수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        return reactor?.currentState.calendarDatas[date]?.count ?? 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let result = DateFormatterManager.shared.checkDaytype(date)
        switch result {
        case .sat:
            return .wheetBlue
        case .sun:
            return .wheetPink
        case .other:
            return nil
        }
    }
    
    /// 캘린더 페이지 변경시 호출되는 메서드
    /// - Parameter calendar: FSCalendar
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print(calendar.currentPage)
        reactor?.action.onNext(.calendarDidChange(calendar.currentPage))
    }
}

// MARK: 뒤로가기 세팅 + 네비게이션
extension CalendarMemoViewController {
    private func navigationSetting() {
        navigationItem.title = "날짜별 찾아보기"
        navigationItem.leftBarButtonItem = backButton()
    }
    
    private func backButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(
            systemItem: .close,
            primaryAction: .guardSelf(
                self, handler: { owner, _ in
                    owner.coordinator?.dismiss()
                }
            )
        )
        return button
    }
}
