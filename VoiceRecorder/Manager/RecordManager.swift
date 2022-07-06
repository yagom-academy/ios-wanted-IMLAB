//
//  RecordManager.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit
import AVFoundation
import Accelerate

class RecordManager: NSObject, AVAudioPlayerDelegate {
    var recorder: AVAudioRecorder?
    var audioPlayer = AVAudioPlayer()
    var audioFile: URL!
    
    var timer: Timer?
    var currentSample: Int = 0
    var soundSamples = [Float](repeating: 0, count: 10)
    
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
    
    func makePlayer() -> AVAudioFile? {
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
//            audioPlayer.prepareToPlay()
//            audioPlayer.delegate = self
//        } catch let error {
//            print("Make Player Error: \(error)")
//        }
        
        do {
            let newAudioFile = try AVAudioFile(forReading: audioFile)
            return newAudioFile
        } catch let error {
            print("fileDir -> file error : \(error)")
            return nil
        }
    }

    func startRecord() {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0] // network static
        
        audioFile = docsDir.appendingPathComponent("record.m4a")
        
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
            recorder?.record()
            
            recorder?.isMeteringEnabled = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                self.recorder?.updateMeters()
                self.soundSamples[self.currentSample] = self.recorder?.averagePower(forChannel: 0) ?? 0
                self.currentSample = (self.currentSample + 1) % 10
            })
        } catch {
            print("Record Error: \(error.localizedDescription)")
        }
    }
    
    func endRecord() {
//        var fileName = dateToFileNamdate(Date())
        timer?.invalidate()
        
        recorder?.stop()
        recorder = nil
    }

    func dateToFileName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let fileName = formatter.string(from: Date())
        return fileName
    }
}

extension RecordManager {
    func startPlay() {
        audioPlayer.play()
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying
    }
    
    func pausePlay() {
        audioPlayer.pause()
    }
}
