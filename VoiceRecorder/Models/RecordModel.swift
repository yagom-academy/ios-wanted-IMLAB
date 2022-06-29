//
//  RecordModel.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/27.
//

import Foundation
import AVFoundation

struct RecordModel: Equatable {
    
    let name: String
    let data: Data
    
    var playTime: String {
        return String(duration.toString.dropLast(3))
    }
    
    private var duration: TimeInterval {
        let audioPlayer = try! AVAudioPlayer(data: data)
        return audioPlayer.duration
    }
}
