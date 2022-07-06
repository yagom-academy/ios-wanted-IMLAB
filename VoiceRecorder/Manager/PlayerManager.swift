//
//  PlayerManager.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import AVFoundation
import Foundation

protocol PlayerService {
    func setAudioFile(_ audioFile: AVAudioFile?)

    func resetAudio()
    func configureAudioEngine()
    func setPlayerToZero()

    func startPlayer()
    func pausePlayer()

    func skip(_ calc: @escaping (Int64, Int64) -> Int64)
    func seek(to time: Double)
    func updateTime()

    func setVolume(_ value: Float)
    func setPitch(_ value: Int)

    func duration() -> String
}

class PlayerManager: PlayerService {
    static let shared = PlayerManager()
    private init() {}

    private var audioFile: AVAudioFile?
    private var audioPlayer = AVAudioPlayerNode()

    private let audioEngine = AVAudioEngine()
    private let speedControl = AVAudioUnitVarispeed()
    private let pitchControl = AVAudioUnitTimePitch()

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0

    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0
    private var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }

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

    func resetAudio() {
//        audioFile = nil

        audioPlayer.stop()
        audioPlayer.reset()

        audioEngine.stop()
        audioEngine.reset()
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

            setVolume(0.5)

            audioLengthSamples = audioFile.length
            audioSampleRate = audioFile.processingFormat.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate

            try audioEngine.start()
        } catch {
            print("error")
        }
    }

    func setPlayerToZero() {
        guard let audioFile = audioFile else {
            return
        }
        audioPlayer.stop()

        let frameCount = AVAudioFrameCount(audioLengthSamples)

        audioPlayer.scheduleSegment(audioFile, startingFrame: 0, frameCount: frameCount, at: nil) {
            print("scheduled")
        }
    }

    // 재생
    func startPlayer() {
        audioPlayer.play()
    }

    // 일시정지
    func pausePlayer() {
        audioPlayer.pause()
    }

    // 5초 앞,뒤로 건너뛰기
    // escaping closure (-, +) 각각 빼기 더하기
    func skip(_ calc: @escaping (Int64, Int64) -> Int64) {
        seek(to: Double(calc(0, 5)))
    }

    func seek(to time: Double) {
        guard let audioFile = audioFile else {
            return
        }

        guard let nodeTime: AVAudioTime = audioPlayer.lastRenderTime,
              let playerTime: AVAudioTime = audioPlayer.playerTime(forNodeTime: nodeTime) else {
            return
        }
        let currentSeconds = Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
        currentPosition += AVAudioFramePosition(currentSeconds * audioSampleRate)

        let offset = AVAudioFramePosition(time * audioSampleRate)

        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame


        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()

        if seekFrame < audioLengthSamples {
            updateTime()

            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)

            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            )

            if wasPlaying {
                audioPlayer.play()
            }
        }
    }

    func updateTime() {
        if currentPosition >= audioLengthSamples {
            audioPlayer.stop()

            seekFrame = 0
            currentPosition = 0
        }
    }

    func setVolume(_ value: Float) {
        audioPlayer.volume = value
    }

    func setPitch(_ value: Int) {
        var audioPitch: Float = 0

        if value == 1 {
            audioPitch = 1000
        } else if value == 2 {
            audioPitch = -500
        }

        pitchControl.pitch = audioPitch
    }

    func duration() -> String {
        if audioLengthSeconds == 0.0 {
            return ""
        }

        let duration = Int(audioLengthSeconds)
        var result = ""

        let min = duration / 60
        let sec = duration % 60

        result += min < 10 ? "0\(min):" : "\(min)"
        result += sec < 10 ? "0\(sec)" : "\(sec)"

        return result
    }
}
