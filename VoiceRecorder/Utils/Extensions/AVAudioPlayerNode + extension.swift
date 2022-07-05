//
//  AVAudioPlayerNode + extension.swift
//  VoiceRecorder
//
//  Created by BH on 2022/07/04.
//

import Foundation
import AVFoundation

extension AVAudioPlayerNode {

    var current: TimeInterval {
        if let nodeTime = lastRenderTime,
           let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}
