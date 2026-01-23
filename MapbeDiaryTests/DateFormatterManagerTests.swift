//
//  DateFormatterManagerTests.swift
//  MapbeDiaryTests
//
//  Created by Codex on 2025-02-18.
//

import XCTest
@testable import MapbeDiary

final class DateFormatterManagerTests: XCTestCase {
    func test_checkDaytype_returnsSaturday() {
        let calendar = Calendar.current
        let date = calendar.nextDate(
            after: Date(),
            matching: DateComponents(weekday: 7),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? Date()
        let dayType = DateFormatterManager.shared.checkDaytype(date)

        XCTAssertEqual(dayType, .sat)
    }

    func test_calendarCheck_matchesSameDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .current
        components.year = 2024
        components.month = 3
        components.day = 9
        components.hour = 10
        let first = components.date ?? Date()

        components.hour = 22
        let second = components.date ?? Date()

        let result = DateFormatterManager.shared.calendarCheck(first, compareFor: second)

        XCTAssertTrue(result)
    }

    func test_calendarCheck_detectsDifferentDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .current
        components.year = 2024
        components.month = 3
        components.day = 9
        components.hour = 10
        let first = components.date ?? Date()

        components.day = 10
        let second = components.date ?? Date()

        let result = DateFormatterManager.shared.calendarCheck(first, compareFor: second)

        XCTAssertFalse(result)
    }

    func test_calendarStartEnd_returnsStartOfDayAndNextDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .current
        components.year = 2024
        components.month = 3
        components.day = 9
        components.hour = 15
        let date = components.date ?? Date()

        let result = DateFormatterManager.shared.calendarStartEnd(date: date)
        let expectedStart = calendar.startOfDay(for: date)
        let expectedEnd = calendar.date(byAdding: .day, value: 1, to: expectedStart)

        XCTAssertEqual(result.start, expectedStart)
        XCTAssertEqual(result.end, expectedEnd)
    }

    func test_monthStartEnd_returnsMonthRange() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .current
        components.year = 2024
        components.month = 3
        components.day = 20
        let date = components.date ?? Date()

        let result = DateFormatterManager.shared.monthStartEnd(date: date)

        let expectedStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        let expectedEnd = calendar.date(byAdding: .month, value: 1, to: expectedStart ?? date)

        XCTAssertEqual(result.start, expectedStart)
        XCTAssertEqual(result.end, expectedEnd)
    }
}
