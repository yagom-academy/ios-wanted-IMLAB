//
//  TempViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/06.
//

import Foundation

class RecordViewModel {
    private let playerModel = PlayerModel(RecordNetworkManager.shared)
    private var audioPlayer: PlayerService!

    var playControllerViewModel: PlayControllerViewModel!
    var recordControllerViewModel: RecordControllerViewModel!

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer

        playControllerViewModel = PlayControllerViewModel(audioPlayer)
        recordControllerViewModel = RecordControllerViewModel(audioPlayer)
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
