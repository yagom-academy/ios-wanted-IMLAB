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
    let audioPlayManager: AudioPlayManager
    
    init(audioInformation: AudioInformation, audioPlayManager: AudioPlayManager = AudioPlayManager()) {
        self.audioInformation = audioInformation
        self.audioPlayManager = audioPlayManager
    }
    
}
