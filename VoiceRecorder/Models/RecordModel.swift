//
//  RecordModel.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/27.
//

import Foundation
import AVFoundation

struct RecordModel: Equatable, Hashable {
    
    let name: String
    let url: URL
    let duration: String
    
    var audioPlayer: AudioPlayer {
        let player = AudioPlayer()
        player.url = url
        player.setupPlayer()
        return player
    }
}
