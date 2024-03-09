//
//  DateFormetter.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/9/24.
//

import Foundation

class DateFormetters {
    private init() {}
    
    static let shared = DateFormetters()
    private let dateformetter = ISO8601DateFormatter()
    private let timeformetter = DateFormatter()
    
    // 2024-03-09T07:27:03.815Z
    func localDate(_ dateString: String) -> String{
        dateformetter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateformetter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = dateformetter.date(from: dateString) else {
            return ""
        }
        // 로케일에 따른 지역화
        let outDateFormetter = DateFormatter()
        outDateFormetter.locale = .current
        outDateFormetter.setLocalizedDateFormatFromTemplate("yyMdHH")
        
        let results = outDateFormetter.string(from: date)
        print(results)
        return results
    }
    
    func localDate(_ date: Date) -> String {
        timeformetter.locale = .current
        timeformetter.timeZone = .current
        timeformetter.dateStyle = .long
        
        let someString = timeformetter.string(from: date)
        return someString
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
