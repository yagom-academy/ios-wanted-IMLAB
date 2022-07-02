//
//  AudioSessionManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/07/02.
//

import UIKit
import AVFoundation

class AudioSessionManager{
    
    let audioSession = AVAudioSession.sharedInstance()

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
}

