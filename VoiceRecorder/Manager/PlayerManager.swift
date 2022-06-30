//
//  PlayerManager.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import AVFoundation
import Foundation

class PlayerManager {
    var url: URL!
    var playerItem: AVPlayerItem?
    var audioPlayer = AVPlayer()

    let TIMESCALE: CMTimeScale = 1000000000
    let SEEK_TIME: Int64 = 5000000000

    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }

    // player 초기화
    func setPlayerItem(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else {
            return
        }

        self.playerItem = playerItem
        audioPlayer.replaceCurrentItem(with: playerItem)
        
//        audioFile = AVAudioFile(
    }
    
    func setPlayerToZero() {
        pausePlayer()
        audioPlayer.seek(to: CMTime(value: 0, timescale: TIMESCALE))
    }

    // 재생
    func startPlayer() {
        print("play")
        audioPlayer.play()
    }

    // 일시정지
    func pausePlayer() {
        audioPlayer.pause()
    }

    // 5초 앞,뒤로 건너뛰기
    // escaping closure (-, +) 각각 빼기 더하기
    func seek(_ calc: @escaping (Int64, Int64) -> Int64) {
        let currentTime = audioPlayer.currentTime()
        let newTime = calc(currentTime.value, SEEK_TIME)
        audioPlayer.seek(to: CMTime(value: newTime, timescale: TIMESCALE))
    }
    
    func setVolume(_ value: Float) {
        audioPlayer.volume = value
    }
}
