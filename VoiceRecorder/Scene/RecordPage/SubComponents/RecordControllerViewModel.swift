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

    init(_ audioPlayer: PlayerService, _ audioRecorder: RecordService) {
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder
    }
    
    func setAudioFile(_ audioFile: AVAudioFile) {
        audioPlayer.setAudioFile(audioFile)
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
}
