//
//  RecordManager.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit
import AVFoundation

protocol RecordService {
    func initRecordSession()
    func normalizeSoundLevel(_ level: Float?) -> Int
    func dateToFileName(_ date: Date) -> String
}

class RecordManager: RecordService {
    var recorder: AVAudioRecorder?
    var audioFile: URL!
    var timer: Timer?
    var waveForms = [Int](repeating: 0, count: 200)
    
    func initRecordSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            audioSession.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Permission Allowed")
                    } else {
                        print("Permission Fail")
                    }
                }
            }
        } catch {
            print("init Session Error: \(error.localizedDescription)")
        }
    }
    
    func normalizeSoundLevel(_ level: Float?) -> Int {
        guard let level = level else { return 0 }
        let lowLevel: Float = -70
        let highLevel: Float = -10
        
        var normalLevel = max(0.0, level - lowLevel)
        normalLevel = min(normalLevel, highLevel - lowLevel)
        
        return Int(normalLevel)
    }

    func dateToFileName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let fileName = formatter.string(from: Date())
        return fileName
    }
}
