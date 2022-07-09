//
//  DataFormatter.swift
//  VoiceRecorder
//
//  Created by 조성빈 on 2022/06/29.
//

import Foundation

class DataFormatter {
    static func makeFileName() -> String {
        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "_yyyy_MM_dd_HH:mm:ss"
        let currentDateString = formatter.string(from: Date())
        return currentDateString
    }
}
