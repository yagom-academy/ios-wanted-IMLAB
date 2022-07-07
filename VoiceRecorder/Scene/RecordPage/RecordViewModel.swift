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
    private var audioRecorder: RecordService!

    var playControllerViewModel: PlayControllerViewModel!
    var recordControllerViewModel: RecordControllerViewModel!

    init(_ audioPlayer: PlayerService, _ audioRecorder: RecordService) {
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder

        playControllerViewModel = PlayControllerViewModel(audioPlayer)
        recordControllerViewModel = RecordControllerViewModel(audioPlayer, audioRecorder)
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
