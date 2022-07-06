//
//  RecordViewModel.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/02.
//

import Foundation
import AVFAudio
import Combine

class RecordViewModel {
    let storage = FirebaseStorageManager.shared
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    var recordFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: true)
    let recordFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("input.m4a"))
    
    init() {
        prepareRecorder()
    }
    
    func prepareRecorder() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            recorder = try AVAudioRecorder(url: recordFileURL, settings: recordFormat!.settings)
        } catch {
            print("Could not Prepare Recorder \(error)")
        }
    }
    
    func startRec() {
        recorder.record()
        recorder.isMeteringEnabled = true

        
        DispatchQueue.global().async {
            while self.recorder.isRecording {
                self.recorder.updateMeters()
                self.writeWave()
            }
        }
        self.writeWave()
    }
    
    func stopRec() {
        recorder.stop()
        
        storage.uploadData(url: recordFileURL, fileName: Date().toString("yyyy_MM_dd_HH:mm:ss"))
    }
    
    func playAudio() {
        do {
            player = try AVAudioPlayer(data: getDataFrom())
            player.play()
            print("play audio")
            print(player.settings)
        } catch {
            print("Fail to play audio")
        }
    }
    
    func stopAudio() {
        player.pause()
    }
    
    func getDataFrom() -> Data {
        guard let data = try? Data(contentsOf: recordFileURL) else {
            print("Data is Not Unwrapping")
            return Data()
        }
        print(data.description)
        return data
    }
    
    func writeWave() {
//        print(self.recorder.averagePower(forChannel: 0))
        
//        print(AVAudioPlayer().settings.keys)
        
    }

}

