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
//    var playerItem: AVPlayerItem?
//    var audioPlayer = AVPlayer()
    var audioFile: AVAudioFile?
    var audioPlayer = AVAudioPlayerNode()

    let audioEngine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    let TIMESCALE: CMTimeScale = 1000000000
    let SEEK_TIME: Int64 = 5000000000

    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }

    func setAudioFile(_ audioFile: AVAudioFile?) {
        guard let audioFile = audioFile else {
            return
        }
        self.audioFile = audioFile

        configureAudioEngine()
    }

    func configureAudioEngine() {
        audioEngine.attach(audioPlayer)
        audioEngine.attach(speedControl)
        audioEngine.attach(pitchControl)

        audioEngine.connect(audioPlayer, to: speedControl, format: nil)
        audioEngine.connect(speedControl, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)

        guard let audioFile = audioFile else {
            return
        }
        do {
            audioPlayer.scheduleFile(audioFile, at: nil)
            try audioEngine.start()
        } catch {
            print("error")
        }
    }

    func setPlayerToZero() {
//        audioPlayer.stop()
//        audioPlayer.seek(to: CMTime(value: 0, timescale: TIMESCALE))
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
//        let currentTime = audioPlayer.currentTime()
//        let newTime = calc(currentTime.value, SEEK_TIME)
//        audioPlayer.seek(to: CMTime(value: newTime, timescale: TIMESCALE))

        guard let nodeTime = audioPlayer.lastRenderTime else { return }
        guard let playerTime = audioPlayer.playerTime(forNodeTime: nodeTime) else { return }
        var sampleRate = playerTime.sampleRate
        
        var newSampleTime = AVAudioFramePosition(sampleRate * 5.0)
        
        print(nodeTime)
        print(playerTime)
        print(sampleRate)
    }

    func setVolume(_ value: Float) {
        audioPlayer.volume = value
    }
}
