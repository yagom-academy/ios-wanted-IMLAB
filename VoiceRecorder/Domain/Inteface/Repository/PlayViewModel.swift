//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by 오국원 on 2022/07/06.
//

import UIKit
import AVFoundation

final class PlayViewModel: AudioPlayViewModelable {
    
    var audioInformation: AudioInformation
    var currentTime: Observable<Double> = Observable(.zero)
    var audioPlayManager: AudioPlayManager
    
    init(audioInformation: AudioInformation) {
        self.audioInformation = audioInformation
        self.audioPlayManager = AudioPlayManager(audioURL: audioInformation.fileURL)
        audioPlayManager.delegate = self
    }
}

// MARK: - AudioPlayDelegate

extension PlayViewModel: AudioPlayDelegate {
    
    func updateCurrentTime() {
        currentTime.value = audioPlayManager.currentTime
    }
}
