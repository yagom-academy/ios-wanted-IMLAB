//
//  SpeedViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/07.
//

import Foundation

class SpeedViewModel {
    private var audioPlayer: PlayerService

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
    }

    func changeSpeed(_ calc: @escaping (Float, Float) -> Float) -> Float {
        return audioPlayer.setSpeed(calc(0.0, 0.1))
    }
}
