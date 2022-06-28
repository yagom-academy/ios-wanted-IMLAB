//
//  Date+.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/28.
//

import Foundation

extension Date {
    var dateToString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "y.MM.dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
