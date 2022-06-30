//
//  AVPlayer+.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        print(currentItem)
        guard currentItem != nil else { return false }
        return rate != 0
    }
}
