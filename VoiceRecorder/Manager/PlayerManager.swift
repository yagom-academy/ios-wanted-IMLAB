//
//  PlayerManager.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import AVFoundation
import Foundation

class PlayerManager {
    var url: URL
    var audioPlayer: AVPlayer?

    let TIMESCALE: CMTimeScale = 1000000000
    let SEEK_TIME: Int64 = 5000000000

    init(url: URL) {
        self.url = url
    }

    // player 초기화
    func initPlayer() {
        if audioPlayer == nil {
            audioPlayer = AVPlayer()
        }

        let playerItem = AVPlayerItem(url: url)
        audioPlayer!.replaceCurrentItem(with: playerItem)
    }

    // 재생
    func startPlayer() {
        if audioPlayer == nil {
            initPlayer()
        }

        audioPlayer!.play()
    }

    // 일시정지
    func pausePlayer() {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
        } else {
            print("no audio player found")
        }
    }

    // 5초 앞,뒤로 건너뛰기
    // escaping closure (-, +) 각각 빼기 더하기
    func seek(_ calc: @escaping (Int64, Int64) -> Int64) {
        guard let currentTime = audioPlayer?.currentTime() else {
            return
        }

        let newTime = calc(currentTime.value, SEEK_TIME)
        audioPlayer?.seek(to: CMTime(value: newTime, timescale: TIMESCALE))
    }
}
