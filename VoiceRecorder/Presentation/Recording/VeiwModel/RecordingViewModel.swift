//
//  RecordingViewModel.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/08.
//

import Foundation
import AVFAudio
import AVFoundation

final class RecordingViewModel {
    
    var repository = FirebaseRepository()
    var audioRecorder: AVAudioRecorder?
    
    private var endPoint: FirebaseRepository.AudioName?
    
    var recordURL: URL {
        let documentsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }()
        let fileName = UUID().uuidString + ".m4a"
        let url = documentsURL.appendingPathComponent(fileName)
        return url
    }
    
    init() {
        setupRecorder()
    }
    
    private func setupRecorder() {
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 320_000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44_100.0
        ]
        
        audioRecorder = try? AVAudioRecorder(url: recordURL, settings: recorderSettings)
        audioRecorder?.prepareToRecord()
    }
    
    func allowed() {
        if let recorder: AVAudioRecorder = self.audioRecorder {
            if recorder.isRecording {
                stopRecording()
            }
        }
    }
    
    func upload(from url: URL) {
        let endPoint = repository.upload(from: url)
        self.endPoint = endPoint
    }
    
    func record() {
        if let recorder: AVAudioRecorder = self.audioRecorder {
            let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
            } catch {
                fatalError(error.localizedDescription)
            }
            recorder.record()
        }
    }
    
    func stopRecording() {
        if let recorder: AVAudioRecorder = self.audioRecorder {
            recorder.stop()
            let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
