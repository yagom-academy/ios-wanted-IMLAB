//
//  AudioRecorderHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

class AudioRecoderHandler {
    
    var audioRecorder = AVAudioRecorder()
    let localFileURL = LocalFileHandler().localFileURL
    let recordFileName = LocalFileHandler().localFileName
    let recordSettings: [String: Any] = [
        AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 441000.0
    ]
    
    func prepareToRecord() {
        do {
            let recordFileURL = localFileURL.appendingPathComponent("\(recordFileName).m4a")
            let audioRecorder = try AVAudioRecorder(url: recordFileURL, settings: recordSettings)
            self.audioRecorder = audioRecorder
            self.audioRecorder.prepareToRecord()
            print(recordFileURL)
        } catch let error {
            print("Error : setUpRecord - \(error)")
        }
    }
    
    func startRecord() {
        self.prepareToRecord()
        self.audioRecorder.record()
    }
    
    func stopRecord() {
        self.audioRecorder.stop()
        let recordFileURL = localFileURL.appendingPathComponent("\(recordFileName).m4a")
        UploadRecordfile().uploadToFirebase(fileUrl: recordFileURL, fileName: recordFileName)
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
}
