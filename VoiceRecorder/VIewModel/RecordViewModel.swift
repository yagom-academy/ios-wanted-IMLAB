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
            
            let recordSetting: [String:Any] = [
                AVFormatIDKey:NSNumber(value: kAudioFileMPEG4Type as UInt32),
                AVEncoderAudioQualityKey:AVAudioQuality.high,
                AVEncoderBitRateKey:16,
                AVEncoderBitRatePerChannelKey:2,
                AVSampleRateKey:44100.0
            ]
            
            recorder = try AVAudioRecorder(url: recordFileURL, settings: recordSetting)
            
        } catch {
            print("Could not Prepare Recorder \(error)")
        }
    }
    
    func startRec() {
        recorder.record()
        recorder.isMeteringEnabled = true
        print("Start record")
        print(recorder.isRecording)
    }
    
    func stopRec() {
        recorder.stop()
    }
    
    func playAudio() {
        do {
            player = try AVAudioPlayer(data: getDataFrom())
            player.play()
            print("play audio")
        } catch {
            print("Fail to play audio")
        }
    }
    
    func getDataFrom() -> Data {
        guard let data = try? Data(contentsOf: recordFileURL) else {
            print("Data is Not Unwrapping")
            return Data()
        }
        print(data.description)
        return data
    }
}

