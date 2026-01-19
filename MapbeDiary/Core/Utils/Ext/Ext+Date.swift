//
//  Ext+Date.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/19/26.
//

import Foundation

extension Date {
    func localDate() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateStyle = .long
        
        let someString = dateFormatter.string(from: self)
        return someString
    }
}
