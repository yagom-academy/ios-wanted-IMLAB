//
//  RecordPermissionManager.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/09.
//

import Foundation
import AVFAudio

protocol RecordPermissionManageable {
    func requestMicrophoneAccess(completion: @escaping (Bool) -> Void)
}

struct RecordPermissionManager: RecordPermissionManageable {
    
    func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
            
        case .undetermined:
            audioSession.requestRecordPermission({ allowed in
                completion(allowed)
            })
        case .denied:
            print("[Failure] Record Permission is Denied.")
            completion(false)
            
        case .granted:
            print("[Success] Record Permission is Granted.")
            completion(true)
        @unknown default:
            fatalError("[ERROR] Record Permission is Unknown Default.")
        }
    }
}
