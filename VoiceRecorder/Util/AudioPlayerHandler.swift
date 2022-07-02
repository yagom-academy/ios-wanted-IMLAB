//
//  AudioPlayerHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

class AudioPlayerHandler {
    
    var audioPlayer = AVAudioPlayer()
    var localFileHandler: LocalFileProtocol
    var updateTimeInterval: UpdateTimer
    
    init(handler: LocalFileProtocol, updateTimeInterval: UpdateTimer) {
        self.localFileHandler = handler
        self.updateTimeInterval = updateTimeInterval
    }
    
    func selectPlayFile(_ fileName: String?) {
        var recordFileURL = localFileHandler.localFileURL
        if fileName == nil {
            let latestRecordFileName = localFileHandler.getLatestFileName()
            let latestRecordFileURL = localFileHandler.localFileURL.appendingPathComponent(latestRecordFileName)
            recordFileURL = latestRecordFileURL
        } else {
            guard let playFileName = fileName else { return }
            let selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("voiceRecords_\(playFileName)")
            recordFileURL = selectedFileURL
        }
        prepareToPlay(recordFileURL)
    }
    
    func prepareToPlay(_ recordFileURL: URL) {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: recordFileURL)
            self.audioPlayer = audioPlayer
            self.audioPlayer.prepareToPlay()
        } catch let error {
            print("Error : setUpPlayer - \(error)")
        }
    }
    
    func startPlay(isSelectedFile: Bool, fileName: String? = nil) {
        if fileName != nil {
            selectPlayFile(fileName)
            self.audioPlayer.play()
        } else {
            selectPlayFile(nil)
            self.audioPlayer.play()
        }
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
}
