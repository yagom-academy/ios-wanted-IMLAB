//
//  RecordVoiceManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/30.
//

import Foundation
import AVFoundation

class RecordVoiceManager{
    var recorder : AVAudioRecorder?
    
    init(){
        self.recorder = nil // 초기화
        let soundFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myRecoding.m4a")
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
          ]
        
        do {
            try recorder = AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder?.prepareToRecord()
            recorder?.isMeteringEnabled = true
        } catch {
            print("audioSession Error: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        self.recorder?.record()
    }
    
    func stopRecording(completion : @escaping ()->Void) {
        self.recorder?.stop()
        // 파일 업로드
//        FirebaseStorageManager().uploadRecord {
//            completion()
//        }
        // 당장은 서버에 업로드 되지 않게 처리(테스트 해봐야 하니까)
    }
    
    func isRecording() -> Bool {
        return self.recorder?.isRecording ?? false
    }
}
