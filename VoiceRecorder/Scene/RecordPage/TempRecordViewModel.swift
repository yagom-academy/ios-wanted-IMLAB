//
//  TempViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/06.
//

import Foundation

class TempRecordViewModel {
    private let playerModel = PlayerModel()
    private var audioPlayer: PlayerService!

    var playerButtonViewModel = PlayerButtonViewModel()

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
