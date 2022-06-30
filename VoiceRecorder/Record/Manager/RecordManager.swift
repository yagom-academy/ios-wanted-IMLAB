//
//  RecordManager.swift
//  VoiceRecorder
//
//  Created by Mac on 2022/06/29.
//

import UIKit
import AVFoundation

class RecordManager: NSObject, AVAudioPlayerDelegate {
    var recorder: AVAudioRecorder?
    var audioPlayer = AVAudioPlayer()
    var audioFile: URL!
    
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
    
    func makePlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
        } catch let error {
            print("Make Player Error: \(error)")
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
        } catch {
            print("Record Error: \(error.localizedDescription)")
        }
    }
    
    func endRecord() {
//        var fileName = dateToFileName(Date())
        recorder?.stop()
        recorder = nil
    }

    private func dateToFileName(_ date: Date) -> String {
        var FileName = "voiceRecords_"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        FileName += formatter.string(from: Date())
        return FileName
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
}
