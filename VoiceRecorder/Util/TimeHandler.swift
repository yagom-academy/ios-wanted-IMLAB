//
//  UpdateTimformater.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/30.
//

import Foundation

class TimeHandler : TimeProtocol {
    func convertNSTimeToString(_ time: TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
}
