//
//  TimeFormatter.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation

class MyDateFormatter {

    static let shared = MyDateFormatter()

    private init() {}

    private let calendarDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    func calendarDateString(from date: Date) -> String {
        calendarDateFormatter.string(from: date)
    }

}
