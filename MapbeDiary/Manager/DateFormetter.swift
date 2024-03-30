//
//  DateFormetter.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation


final class DateFormetters {
    private init() {}
    
    static let shared = DateFormetters()
    
    private let dateformetter = ISO8601DateFormatter()
    private let timeformetter = DateFormatter()
    private let calendar = Calendar.current
    
    // 2024-03-09T07:27:03.815Z
    func localDate(_ dateString: String) -> String{
        // ISO8601DateFormatter의 옵션을 설정합니다.
        dateformetter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // 타임존을 영국으로 잡습니다.(그리니치 천문대)
        dateformetter.timeZone = TimeZone(secondsFromGMT: 0)
        // 클라이언트에게 받는 문자열을 Date로 변환하려합니다.
        guard let date = dateformetter.date(from: dateString) else {
            return ""
        }
        // 로케일에 따른 지역화
        // 출력 날짜형식인 DateFormatter를 생성하고
        // 현재 로케일을 설정한다.
        let outDateFormetter = DateFormatter()
        outDateFormetter.locale = .current
        
        // 형식 정하기
        outDateFormetter.setLocalizedDateFormatFromTemplate("yyMdHH")
        // 변환할 날짜 문자열을 반환한다.
        let results = outDateFormetter.string(from: date)
        print(results)
        
        return results
    }
    
    func localDate(_ date: Date) -> String {
        // timeformetter(사실 Date)
        // 현재 로케일과 현재 타임존으로 설정
        timeformetter.locale = .current
        timeformetter.timeZone = .current
        
        // 날짜 스타일을 long으로 하여 형식을 지정
        timeformetter.dateStyle = .long
        // 문자열로 변환하여 반환
        let someString = timeformetter.string(from: date)
        return someString
    }
    
    func calendarCheck(_ date: Date, compareFor: Date) -> Bool {
        let first = calendar.dateComponents([.year,.month,.day], from: date)
        let second = calendar.dateComponents([.year,.month,.day], from: compareFor)
        
        return  first.year == second.year &&
                first.month == second.month &&
                first.day == second.day
        
    }
    
    func calendarStartEnd(date: Date) -> (start: Date, end: Date) {
        let start = calendar.startOfDay(for: date)
        print(start,"시작")
        let end = calendar.date(byAdding: .day, value: 1, to: start)
        return (start, end ?? Date())
    }
}

/*
 // (3) 날짜 형식 선택
 formatter.dateStyle = .full           // "Friday, January 6, 2023"
 //formatter.dateStyle = .long         // "January 6, 2023"
 //formatter.dateStyle = .medium       // "Jan 6, 2023"
 //formatter.dateStyle = .none         // (날짜 없어짐)
 //formatter.dateStyle = .short        // "1/6/23"
 */
