//
//  DateUtil.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/07/04.
//

import Foundation

class DateUtil {
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: Date())
    }
    
    static func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(from: dateString) ?? Date()
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        return formatter.string(from: date)
    }
    
}
