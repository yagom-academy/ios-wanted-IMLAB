//
//  AVAudioPlayerNode+extension.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/06/29.
//

import Foundation
import AVKit

extension AVAudioPlayerNode {
    
    var currentTime: TimeInterval {
        if let nodeTime = lastRenderTime,let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
    
}
