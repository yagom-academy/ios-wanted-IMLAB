//
//  PlayerManager.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/06/29.
//

import AVFoundation
import Foundation

protocol PlayerService {
    var isPlaying: Bool { get }

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
    func setSpeed(_ value: Float) -> Float

    func duration() -> String
    func checkIsFinished() -> Bool
}

class PlayerManager: PlayerService {
    static let shared = PlayerManager()
    private init() {}

    private var audioFile: AVAudioFile?
    private var audioPlayer = AVAudioPlayerNode()

    private var audioEngine = AVAudioEngine()
    private let pitchControl = AVAudioUnitTimePitch()
    private let speedControl = AVAudioUnitVarispeed()

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0

    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0

    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }

    func setAudioFile(_ audioFile: AVAudioFile?) {
        guard let audioFile = audioFile else {
            return
        }
        resetAudio()
        self.audioFile = audioFile

        configureAudioEngine()
    }

    func resetAudio() {
        audioFile = nil

        audioEngine.stop()
        audioPlayer.stop()

        audioEngine.reset()
        audioPlayer.reset()

        pitchControl.pitch = 0

        seekFrame = 0
        currentPosition = 0
        audioLengthSeconds = 0
        audioLengthSamples = 0
        audioSampleRate = 0

        setVolume(0.5)
    }

    func configureAudioEngine() {
        guard let audioFile = audioFile else {
            return
        }

        audioEngine.attach(audioPlayer)
        audioEngine.attach(pitchControl)
        audioEngine.attach(speedControl)

        audioEngine.connect(audioPlayer, to: speedControl, format: nil)
        audioEngine.connect(speedControl, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)

        do {
            audioPlayer.scheduleFile(
                audioFile,
                at: nil,
                completionCallbackType: .dataPlayedBack
            ) { [weak self] _ in

                guard let self = self else {
                    return
                }
                if self.checkIsFinished() {
                    self.setPlayerToZero()
                }
            }

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
        // UI 와 관련없는 작업을 main 스레드로 보내면,
        // 작업이 오래걸리면 너무 느리게 보일 수 있다.
        // UI 와 관련된 작업은 main 에 태우는게 옳다!!!!

        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }

            self.audioPlayer.stop()
            self.audioEngine.stop()

            self.seekFrame = 0
            self.currentPosition = 0

            self.configureAudioEngine()
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("PlayerDidEnded"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("SendWaveform"), object: Array(repeating: 1, count: 100))
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

        // audioPlayer 새로 스케쥴링하고 지난 시간
        let currentSeconds = Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
        // 기존에 진행되었던 시간값에 더해주기
        currentPosition += AVAudioFramePosition(currentSeconds * audioSampleRate)

        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)

        // currentPosition 을 옮겨줄 시간으로 변경
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
                at: nil,
                completionCallbackType: .dataPlayedBack
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }

                if self.checkIsFinished() {
                    self.setPlayerToZero()
                }
            }
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

    func setSpeed(_ value: Float) -> Float {
        let roundedValue = round(value * 10) / 10
        let roundedRate = round(speedControl.rate * 10) / 10
        let newRate = roundedValue + roundedRate

        if newRate > 1.5 || newRate < 0.5 {
            return speedControl.rate
        }
        speedControl.rate = newRate

        return speedControl.rate
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

    func checkIsFinished() -> Bool {
        guard let nodeTime: AVAudioTime = audioPlayer.lastRenderTime,
              let playerTime: AVAudioTime = audioPlayer.playerTime(forNodeTime: nodeTime) else {
            return false
        }

        let currentSeconds = Double(Double(playerTime.sampleTime) / playerTime.sampleRate) + (Double(currentPosition) / audioSampleRate)

        if currentSeconds >= audioLengthSeconds {
            return true
        } else {
            return false
        }
    }
}
