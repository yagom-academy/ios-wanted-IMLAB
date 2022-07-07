//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by 오국원 on 2022/07/06.
//

import UIKit
import AVFoundation

final class PlayViewModel {
    
    var audioInformation: AudioInformation
    var audioPlayManager: AudioPlayManager
    
    init(audioInformation: AudioInformation) {
        self.audioInformation = audioInformation
        self.audioPlayManager = AudioPlayManager(audioURL: audioInformation.fileURL)
    }
    
    func changePitch(to voice: Int) {
        audioPlayManager.changePitch(to: voice)
    }
    
    func controlVolume(to volume: Float) {
        audioPlayManager.controlVolume(to: volume)
    }
    
    func move(seconds: Double) {
        audioPlayManager.seek(to: seconds)
    }
    
    func play() {
        audioPlayManager.play()
    }
    
    func pause() {
        audioPlayManager.pause()
    }

}
