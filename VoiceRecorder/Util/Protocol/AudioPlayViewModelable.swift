//
//  AudioPlayViewModelable.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/07/09.
//

import Foundation

protocol AudioPlayViewModelable {

    var audioPlayManager: AudioPlayManager { get }
    
    func play()
    func pause()
    func move(seconds: Double)
    func changePitch(to voice: Int)
    func controlVolume(to volume: Float)
}

extension AudioPlayViewModelable {
    
    func play() {
        audioPlayManager.play()
    }
    
    func pause() {
        audioPlayManager.pause()
    }
    
    func move(seconds: Double) {
        audioPlayManager.seek(to: seconds)
    }
    
    func changePitch(to voice: Int) {
        audioPlayManager.changePitch(to: voice)
    }
    
    func controlVolume(to volume: Float) {
        audioPlayManager.controlVolume(to: volume)
    }
}
