//
//  DateExtensions.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/06/28.
//

import Foundation

extension DateFormatter {
//    static let dateFormatter: DateFormatter = {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//        return dateFormatter
//    }()
    
    func toString(_ date: Date, to format: String = "yyyy_MM_dd_HH:mm:ss") -> String {
        self.dateFormat = format
        self.locale = Locale(identifier: "ko_KR")
//        return Self.dateFormatter.string(from: date)
        return self.string(from: date)
    }
}
