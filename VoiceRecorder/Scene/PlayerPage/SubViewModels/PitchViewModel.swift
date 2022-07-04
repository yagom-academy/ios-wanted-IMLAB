//
//  PitchControlViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/04.
//

import Foundation

class PitchViewModel {
    private var audioPlayer = PlayerManager.shared

    func changePitch(_ value: Int) {
        audioPlayer.setPitch(value)
    }
}
