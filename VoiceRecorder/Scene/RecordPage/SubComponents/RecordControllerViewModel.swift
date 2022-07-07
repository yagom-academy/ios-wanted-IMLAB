//
//  RecordControllerViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation
import AVFAudio

struct RecordControllerViewModel {
    private var audioPlayer: PlayerService
    private var audioRecorder: RecordService
    private var network: NetworkManager

    init(_ audioPlayer: PlayerService, _ audioRecorder: RecordService, _ network: NetworkManager) {
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder
        self.network = network
    }
    
    func setAudioFile() {
        guard let audioFile = audioRecorder.audioFile else {
            return
        }
        
        do {
            let newAudioFile = try AVAudioFile(forReading: audioFile)
            return audioPlayer.setAudioFile(newAudioFile)
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    func duration() -> String {
        return audioPlayer.duration()
    }
    
    func initRecordSession() {
        return audioRecorder.initRecordSession()
    }
    
    func startRecord() {
        return audioRecorder.startRecord()
    }
    
    func endRecord() {
        return audioRecorder.endRecord()
    }
    
    func dateToFileName() -> String {
        return audioRecorder.dateToFileName(Date())
    }
    
    func saveRecord(_ file: String) {
        return network.saveRecord(filename: file, completion: nil)
    }
}
