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
    private var audioPlayer = PlayerManager()

    func update(_ filename: String, _ completion: @escaping () -> Void) {
        model.update(filename, completion)
    }

    func getFileData() -> FileData? {
        return model.getFileData()
    }

    func setPlayerItem() {
//        audioPlayer.setPlayerItem(model.getAVPlayerItem())
        audioPlayer.setAudioFile(model.getAVAudioFile())
    }

    func onTappedPlayPauseButton() -> Bool {
        // true -> playing
        // false -> not playing
        if audioPlayer.isPlaying {
            audioPlayer.pausePlayer()
            return false
        } else {
            audioPlayer.startPlayer()
            return true
        }
    }

    func onTappedBackwardButton() {
        audioPlayer.skip(-)
    }

    func onTappedForwardButton() {
        audioPlayer.skip(+)
    }

    func setPlayerToZero() {
        audioPlayer.setPlayerToZero()
    }

    func changedVolumeSlider(_ value: Float) {
        audioPlayer.setVolume(value)
    }

    func changedPitchControl(_ value: Int) {
        audioPlayer.setPitch(value)
    }
}
