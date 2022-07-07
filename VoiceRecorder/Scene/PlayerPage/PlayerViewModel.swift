//
//  PlayerViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerViewModel {
    private let model = PlayerModel(RecordNetworkManager.shared)
    private var audioPlayer: PlayerService!

    var pitchViewModel: PitchViewModel!
    var volumeViewModel: VolumeViewModel!
    var playerButtonViewModel: PlayerButtonViewModel!

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer

        pitchViewModel = PitchViewModel(audioPlayer)
        volumeViewModel = VolumeViewModel(audioPlayer)
        playerButtonViewModel = PlayerButtonViewModel(audioPlayer)
    }

    func update(_ filename: String, _ completion: @escaping (Error?) -> Void) {
        model.update(filename) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

    func getFileData() -> FileData? {
        return model.getFileData()
    }

    func setPlayerItem() {
        audioPlayer.setAudioFile(model.getAVAudioFile())
    }

    func setAudioReady() {
        playerButtonViewModel.isAudioAvailable()
    }

    func setPlayerToZero() {
        audioPlayer.setPlayerToZero()
    }

    func resetAudioPlayer() {
        audioPlayer.resetAudio()
    }
}
