//
//  PlayerTime.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/01.
//

import Foundation

struct PlayerTime {
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = 3600
    }
    
    let elapsedText: String
    let remainingText: String
    static let zero = PlayerTime(elapsedTime: 0, remainingTime: 0)
    
    init(elapsedTime: Double, remainingTime: Double) {
        elapsedText = PlayerTime.formatted(time: elapsedTime)
        remainingText = PlayerTime.formatted(time: remainingTime)
    }
    
    private static func formatted(time: Double) -> String {
        var seconds = Int(ceil(time))
        var hours = 0
        var minutes = 0

        if seconds > TimeConstant.secsPerHour {
            hours = seconds / TimeConstant.secsPerHour
            seconds -= hours * TimeConstant.secsPerHour
        }

        if seconds > TimeConstant.secsPerMin {
            minutes = seconds / TimeConstant.secsPerMin
            seconds -= minutes * TimeConstant.secsPerMin
        }

        var formattedString = ""

        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }

        formattedString += "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        return formattedString
    }
}
