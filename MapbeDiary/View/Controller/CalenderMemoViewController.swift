//
//  CalenderMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import UIKit
import FSCalendar


class CalenderMemoViewController: BaseHomeViewController<CalenderMemoView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        calenderDelegateSetting()
        bind()
        
        firstCome()
    }
    
    private func calenderDelegateSetting(){
        homeView.calenderView.delegate = self
        homeView.calenderView.dataSource = self
    }
    private func bind(){
        homeView.viewModel.reloadTrigger.bind { [weak self] void in
            guard let self,
            void != nil else { return }
            homeView.calenderView.reloadData()
            
        }
        homeView.viewModel.dismissTrigger.bind { [weak self] void in
            guard void != nil else { return }
            self?.dismiss(animated: true)
        }
    }
    
    private func firstCome(){
        let date = Date()
        homeView.calenderView.select(date, scrollToDate: true)
        homeView.viewModel.date.value = date
    }
    
}

extension CalenderMemoViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // MARK: 캘린더 애니메
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        print(bounds)
        print(calendar)
        print(animated)
    }
    
    // MARK: 캘린더 선택 날짜 색상 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return .wheetBlue
    }
    // MARK: 전체 Date 비교 배경색 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if DateFormetters.shared.calendarCheck(Date(), compareFor: date) {
            return .systemPink
        }
        return appearance.borderDefaultColor
    }
    
    // MARK: 전체 Date 비교 배경색 지정
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if DateFormetters.shared.calendarCheck(Date(), compareFor: date) {
            return "today"
        }
        return nil
    }
    
    // MARK: 선택된 날짜 전달
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeView.viewModel.date.value = date
    }
    
    // MARK: 최저 날짜 선택
    func minimumDate(for calendar: FSCalendar) -> Date {
        let result = homeView.viewModel.minDateLocationMemo.value
        guard let result else {
            return .init()
        }
        return result.regdate
    }
    
    // MARK: 최대 날짜 정하기
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    // MARK: 캘린더 이벤트 갯수
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        homeView.viewModel.eventDate.value = date
        return homeView.viewModel.countDate.value ?? 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let result = DateFormetters.shared.checkDaytype(date)
        switch result {
        case .sat:
            return .wheetBlue
        case .sun:
            return .wheetPink
        case .other:
            return nil
        }
    }

    
}

// MARK: 뒤로가기 세팅 + 네비게이션
extension CalenderMemoViewController {
    private func navigationSetting(){
        navigationItem.title = "날짜별 찾아보기"
        navigationItem.leftBarButtonItem = backbutton()
    }
    
    private func backbutton() -> UIBarButtonItem{
        let backbutton = UIBarButtonItem.init(systemItem: .close, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self else { return }
            dismiss(animated: true)
        }))
        return backbutton
    }
}
