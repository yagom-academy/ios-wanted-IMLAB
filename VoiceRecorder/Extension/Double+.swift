//
//  Double+.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/28.
//

import Foundation

extension Double {
    var toString: String {
        let minute = Int(self / 60.0)
        let second = Int(self.truncatingRemainder(dividingBy: 60.0))
        let millisecond = Int(self.truncatingRemainder(dividingBy: 1.0) * 100.0)
        
        var minuteString = String(minute)
        var secondString = String(second)
        var millisecondString = String(millisecond)
        
        if (0..<10) ~= minute {
            minuteString = "0" + minuteString
        }
        if (0..<10) ~= second {
            secondString = "0" + secondString
        }
        if (0..<10) ~= millisecond {
            millisecondString = "0" + millisecondString
        }
        
        return "\(minuteString):\(secondString):\(millisecondString)"
    }
}
