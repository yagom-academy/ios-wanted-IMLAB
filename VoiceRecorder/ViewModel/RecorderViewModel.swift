//
//  RecorderViewModel.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/29.
//

import UIKit
import AVFAudio

struct RecorderViewModel{
    
    private var recorder : AVAudioRecorder?
    
    init(_ url : URL){
        self.recorder = nil // 초기화
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            self.recorder = recorder
            // AVAudioRecorder가 throw를 할 수 있기 때문에 do 사용
        }
        catch {
            print("error")
        }
    }
    
    func startRecording() {
        self.recorder?.prepareToRecord() //init보다는 startRecording 쪽으로 묶이는 게 더 자연스러워 보여서
        self.recorder?.record()
    }
    
    func stopRecording() {
        self.recorder?.stop()
        // 파일 업로드
    }
    
    func isRecording() -> Bool {
        self.recorder?.isRecording ?? false
    }
}
