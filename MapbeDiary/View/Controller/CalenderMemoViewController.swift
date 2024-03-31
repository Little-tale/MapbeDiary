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
        calenderDelegateSetting()
        bind()
    }
    
    private func calenderDelegateSetting(){
        homeView.calenderView.delegate = self
        homeView.calenderView.dataSource = self
    }
    private func bind(){
        homeView.viewModel.folder.value = homeView.viewModel.repository.findAllFolder().first
        
        homeView.viewModel.selectedLocationMemo.bind { [weak self] memo in
            guard let self else { return }
            guard let memo else { return }
            print(memo)
        }
        homeView.viewModel.reloadTrigger.bind { [weak self] void in
            guard let self,
            let void else { return }
            homeView.calenderView.reloadData()
        }
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
    
}
