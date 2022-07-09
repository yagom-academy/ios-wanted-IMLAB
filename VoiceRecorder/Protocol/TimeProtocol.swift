//
//  TimerProtocol.swift
//  VoiceRecorder
//
//  Created by 장주명 on 2022/06/30.
//

import Foundation

protocol TimeProtocol {
    func convertNSTimeToString(_ time: TimeInterval) -> String
}
