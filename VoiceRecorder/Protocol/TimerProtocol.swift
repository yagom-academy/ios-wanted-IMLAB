//
//  TimerProtocol.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/30.
//

import Foundation

protocol UpdateTimer {
    func updateTimer(_ time: TimeInterval) -> String
}
