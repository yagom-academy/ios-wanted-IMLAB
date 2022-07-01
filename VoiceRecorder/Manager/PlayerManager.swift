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

    var audioFile: AVAudioFile?
    var audioPlayer = AVAudioPlayerNode()

    let audioEngine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    var audioLengthSamples: AVAudioFramePosition = 0

    var audioSampleRate: Double = 0
    var audioLengthSeconds: Double = 0
    var currentFrame: AVAudioFramePosition {
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
        // 재생 끝났을때 처음으로
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

        audioSampleRate += time * audioSampleRate
        let offset = AVAudioFramePosition(audioSampleRate)

        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame

        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()

        if currentPosition < audioLengthSamples {
            updateTime()

            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)

            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            ) {
            }

            if wasPlaying {
                audioPlayer.play()
            }
        }
    }

    func updateTime() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)

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
}
