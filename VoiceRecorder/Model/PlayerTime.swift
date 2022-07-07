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
    
<<<<<<< HEAD:VoiceRecorder/Model/PlayTime.swift
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = 3600
    }
    
    static let zero: PlayerTime = PlayerTime.init(elapsedTime: 0, remainingTime: 0)
    
=======
>>>>>>> main:VoiceRecorder/Model/PlayerTime.swift
    init(elapsedTime: Double, remainingTime: Double) {
        elapsedText = PlayerTime.formatted(time: elapsedTime)
        remainingText = PlayerTime.formatted(time: remainingTime)
    }
    
    private static func formatted(time: Double) -> String {
        var seconds = Int(ceil(time))
        var hours = 0
        var minutes = 0

<<<<<<< HEAD:VoiceRecorder/Model/PlayTime.swift
        if seconds > TimeConstant.secsPerHour {
            hours = seconds / TimeConstant.secsPerHour
            seconds -= hours * TimeConstant.secsPerHour
        }

        if seconds > TimeConstant.secsPerMin {
            minutes = seconds / TimeConstant.secsPerMin
            seconds -= minutes * TimeConstant.secsPerMin
=======
        if seconds > TimeConstant.secondsHour {
            hours = seconds / TimeConstant.secondsHour
            seconds -= hours * TimeConstant.secondsHour
        }

        if seconds > TimeConstant.secondsMinute {
            minutes = seconds / TimeConstant.secondsMinute
            seconds -= minutes * TimeConstant.secondsMinute
>>>>>>> main:VoiceRecorder/Model/PlayerTime.swift
        }

        var formattedString = ""

        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }

        formattedString += "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        return formattedString
    }
}
