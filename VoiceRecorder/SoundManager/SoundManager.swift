//
//  SoundManager.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/06/29.
//

import Foundation
import AVFoundation

protocol ReceiveSoundManagerStatus {
    func observeAudioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
}

class SoundManager: NSObject {
    
    var player: AVAudioPlayer!
    
    var delegate: ReceiveSoundManagerStatus?
    
    override init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func initializedPlayer(soundData: Data?) {
        
        guard let data = soundData else { fatalError("Invalid soundData") }
        do {
            try self.player = AVAudioPlayer(data: data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else {
            return
        }
        print("오디오 플레이어 디코드 오류발생\(error)")
        // delegate 오류 메세지 보냄
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.observeAudioPlayerDidFinishPlaying(player, successfully: flag)
    }
}
