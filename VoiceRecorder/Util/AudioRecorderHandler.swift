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
    var fileName: String?
    
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
    
    private func enableBuiltInMic() {
        // Get the shared audio session.
        let session = AVAudioSession.sharedInstance()
        // Find the built-in microphone input.
        guard let availableInputs = session.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            print("The device must have a built-in microphone.")
            return
        }
        // Make the built-in microphone input the preferred input.
        do {
            try session.setPreferredInput(builtInMicInput)
        } catch {
            print("Unable to set the built-in mic as the preferred input.")
        }
    }
    
    func prepareToRecord() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: .allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
            
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("허용함")
                    } else {
                        //mic disabled!
                    }
                }
            }
            
            enableBuiltInMic()
            let recordFileName = localFileHandler.makeFileName()
            let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
            let audioRecorder = try AVAudioRecorder(url: recordFileURL, settings: recordSettings)
            self.fileName = recordFileName
            self.audioRecorder = audioRecorder
            audioRecorder.isMeteringEnabled = true
            self.audioRecorder.prepareToRecord()
        } catch let error {
            print("Error : setUpRecord - \(error)")
        }
    }
    
    func startRecord() {
        self.prepareToRecord()
        self.audioRecorder.record()
    }
    
    func stopRecord(totalTime : String) {
        self.audioRecorder.stop()
        guard let recordFileName = self.fileName else { return }
        let recordFileURL = localFileHandler.localFileURL.appendingPathComponent(recordFileName)
        FirebaseStorage.shared.uploadFile(fileUrl: recordFileURL, fileName: recordFileName, totalTime: totalTime)
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
}
