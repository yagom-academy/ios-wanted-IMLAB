//
//  AVAudioFile + extension.swift
//  VoiceRecorder
//
//  Created by BH on 2022/07/04.
//

import Foundation
import AVFoundation

extension AVAudioFile {

    var duration: TimeInterval{
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }

}
