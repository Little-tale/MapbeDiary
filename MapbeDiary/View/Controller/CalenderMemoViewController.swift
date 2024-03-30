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
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("선택 날짜",date)
        homeView.viewModel.date.value = date
    }
    
    
    
}
