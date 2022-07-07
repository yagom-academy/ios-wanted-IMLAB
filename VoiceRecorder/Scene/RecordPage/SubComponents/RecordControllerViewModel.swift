//
//  RecordControllerViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation
import AVFAudio

struct RecordControllerViewModel {
    private var audioPlayer: PlayerService

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
    }
    
    func setAudioFile(_ audioFile: AVAudioFile) {
        audioPlayer.setAudioFile(audioFile)
    }

    func duration() -> String {
        return audioPlayer.duration()
    }
}
