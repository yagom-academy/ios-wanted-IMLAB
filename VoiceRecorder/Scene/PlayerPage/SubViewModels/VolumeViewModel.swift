//
//  VolumeViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/04.
//

import Foundation

class VolumeViewModel {
    private var audioPlayer: PlayerService

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
    }

    func changedVolume(_ value: Float) {
        audioPlayer.setVolume(value)
    }
}
