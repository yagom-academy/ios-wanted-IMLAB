//
//  PlayerTime.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/01.
//

import Foundation

struct PlayerTime {
    enum TimeConstant {
        static let secondsMinute = 60
        static let secondsHour = 3600
    }
    
    let elapsedText: String
    let remainingText: String
    
    init(elapsedTime: Double, remainingTime: Double) {
        elapsedText = PlayerTime.formatted(time: elapsedTime)
        remainingText = PlayerTime.formatted(time: remainingTime)
    }
    
    private static func formatted(time: Double) -> String {
        var seconds = Int(ceil(time))
        var hours = 0
        var minutes = 0

        if seconds > TimeConstant.secondsHour {
            hours = seconds / TimeConstant.secondsHour
            seconds -= hours * TimeConstant.secondsHour
        }

        if seconds > TimeConstant.secondsMinute {
            minutes = seconds / TimeConstant.secondsMinute
            seconds -= minutes * TimeConstant.secondsMinute
        }

        var formattedString = ""

        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }

        formattedString += "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        return formattedString
    }
}
