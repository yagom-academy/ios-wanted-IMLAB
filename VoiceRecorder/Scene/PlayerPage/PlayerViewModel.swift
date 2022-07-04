//
//  PlayerViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/30.
//

import AVFoundation
import Foundation

class PlayerViewModel {
    private let model = PlayerModel()
    private var audioPlayer = PlayerManager.shared
    
    var pitchViewModel = PitchViewModel()
    var volumeViewModel = VolumeViewModel()
    var playerButtonViewModel = PlayerButtonViewModel()

    func update(_ filename: String, _ completion: @escaping () -> Void) {
        model.update(filename, completion)
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
    
}
