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
    var localFileHandler : LocalFileProtocol
    var updateTimeInterval : UpdateTimer
    
    init(handler : LocalFileProtocol, updateTimeInterval : UpdateTimer ){
        self.localFileHandler = handler
        self.updateTimeInterval = updateTimeInterval
    }
    
    var recordSettings : [String: Any] = [
        AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 441000.0
    ]
    
    func prepareToRecord() {
        do {
            let recordFileURL = localFileHandler.localFileURL.appendingPathComponent("\(localFileHandler.localFileName).m4a")
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
        let recordFileURL = localFileHandler.localFileURL.appendingPathComponent("\(localFileHandler.localFileName).m4a")
        UploadRecordfile().uploadToFirebase(fileUrl: recordFileURL, fileName: localFileHandler.localFileName)
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
}
