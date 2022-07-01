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
    let url: URL
    
    var audioPlayer: AudioPlayer {
        let player = AudioPlayer()
        player.url = url
        player.setupPlayer()
        return player
    }
}
