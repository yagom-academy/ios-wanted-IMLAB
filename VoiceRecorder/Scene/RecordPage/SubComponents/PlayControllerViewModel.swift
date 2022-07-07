//
//  PlayControllerViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation

struct PlayControllerViewModel {
    private var audioPlayer: PlayerService

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
    }

    func playPauseAudio() -> Bool {
        if audioPlayer.isPlaying {
            audioPlayer.pausePlayer()
            return false
        } else {
            audioPlayer.startPlayer()
            return true
        }
    }

    func goBackward() {
        audioPlayer.skip(-)
    }

    func goForward() {
        audioPlayer.skip(+)
    }
}
