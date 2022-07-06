//
//  PlayerButtonViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/04.
//

import AVFAudio
import Foundation

class PlayerButtonViewModel {
    private var audioPlayer = PlayerManager.shared

    func isAudioAvailable() -> Bool {
        return true
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

    func setAudioFile(_ audioFile: AVAudioFile) {
        audioPlayer.setAudioFile(audioFile)
    }
    
    func duration() -> String {
        return audioPlayer.duration()
    }
}
