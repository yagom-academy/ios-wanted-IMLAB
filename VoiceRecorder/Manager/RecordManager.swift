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
    func startRecord()
    func endRecord()
}

class RecordManager: RecordService {
    
    static let shared = RecordManager()
    
    var recorder: AVAudioRecorder?
    var audioFile: URL!
    var timer: Timer?
    var waveForms = [Int](repeating: 0, count: 100)
    
    private init () {}
    
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
    
    func startRecord() {
        var currentSample = 0
        let numberOfSamples = waveForms.count

        audioFile = Config.getRecordFilePath()

        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
            recorder?.record()

            recorder?.isMeteringEnabled = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
                guard let self = self else { return }
                self.recorder?.updateMeters()
                
                let soundLevel = self.normalizeSoundLevel(self.recorder?.averagePower(forChannel: 0))

                if currentSample == numberOfSamples {
                    self.waveForms.removeFirst()
                    self.waveForms.append(soundLevel)
                } else {
                    self.waveForms[currentSample] = soundLevel
                }

                if currentSample < numberOfSamples {
                    currentSample += 1
                }
                
                if self.recorder?.isRecording ?? true {
                    NotificationCenter.default.post(name: Notification.Name("SendWaveform"), object: self.waveForms, userInfo: nil)
                }
            })
        } catch {
            print("Record Error: \(error.localizedDescription)")
        }
    }

    func endRecord() {
        timer?.invalidate()

        recorder?.stop()
        recorder = nil
        
//        guard let audioFile = audioFile else {
//            return
//        }
//
//        do {
//            let newAudioFile = try AVAudioFile(forReading: audioFile)
//            viewModel.setAudioFile(newAudioFile)
//        } catch let error {
//            print("play record file error: \(error)")
//        }
    }
}
