//
//  RecordVoiceManager.swift
//  VoiceRecorder
//
//  Created by hayeon on 2022/06/30.
//

import Foundation
import AVFoundation

protocol RecordVoiceManagerDelegate : AnyObject{
    func updateCurrentTime(_ currentTime : TimeInterval)
}

class RecordVoiceManager{
    var timer : Timer?
    var recorder : AVAudioRecorder?
    weak var delegate : RecordVoiceManagerDelegate?
    
    init(){
        self.recorder = nil
        let soundFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myRecoding.m4a")
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
            self.delegate?.updateCurrentTime(self.recorder?.currentTime ?? 0)
        })
        self.recorder?.record()
        
    }
    
    func stopRecording(completion : @escaping ()->Void) {
        self.recorder?.stop()
        timer?.invalidate()
        completion()
    }
    
    func isRecording() -> Bool {
        return self.recorder?.isRecording ?? false
    }
    
    deinit{
        print("CLOSE RECORDMANAGER")
    }
}
