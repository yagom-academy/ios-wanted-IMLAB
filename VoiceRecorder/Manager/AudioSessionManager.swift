//
//  AudioSessionManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/02.
//

import UIKit
import AVFoundation

class AudioSessionManager{
    
    private let audioSession = AVAudioSession.sharedInstance()

    func setAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord)
            audioSession.requestRecordPermission{ accepted in
                if accepted {
                    print("permission granted")
                }
            }
        } catch {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func setSampleRate(_ sampleRate : Double) {
        do {
            try audioSession.setPreferredSampleRate(sampleRate)
        } catch {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func getSampleRate() -> Double {
        return audioSession.sampleRate
    }
}

