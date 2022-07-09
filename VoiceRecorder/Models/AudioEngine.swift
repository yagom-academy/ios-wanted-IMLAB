//
//  AudioEngine.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/02.
//

import AVKit

class AudioEngine {
    private let engine = AVAudioEngine()
    private let audioPlayer = AVAudioPlayerNode()
    private let speedControl = AVAudioUnitVarispeed()
    private let pitchControl = AVAudioUnitTimePitch()
    private var equalizer: AVAudioUnitEQ?
    
    // 주파수 * 초 = 프레임
    private var audioSampleRate = 0.0 // 현재 주파수
    private var audioLengthSeconds = 0.0 // 총 길이 (초)
    var seekFrame: AVAudioFramePosition = 0 // 이동할 프레임
    var currentPosition: AVAudioFramePosition = 0 // 현재 프레임
    private var audioLengthSamples: AVAudioFramePosition = 0 // 프레임 총 길이
    
    var duration: Double { audioLengthSeconds }
    
    var url: URL?
    var audioFile: AVAudioFile?
    var gains: [Float] = [0, 0, 0, 0, 0]
    
    func setupEngine() throws {
        guard let url = url else { return }
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        audioFile = file
        let equalizer = AVAudioUnitEQ(numberOfBands: 5)
        let bands = equalizer.bands
        let freqs = [75, 250, 1040, 2500, 7500]
        
        for i in 0..<bands.count {
            bands[i].frequency = Float(freqs[i])
            bands[i].filterType = i <= 2 ? .lowShelf : .highShelf
            bands[i].gain = Float(gains[i])
            bands[i].bypass = false
        }

        audioLengthSamples = file.length
        audioSampleRate = format.sampleRate
        audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
        
        audioPlayer.volume = 0.5
        
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        engine.attach(equalizer)
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: equalizer, format: nil)
        engine.connect(equalizer, to: engine.mainMixerNode, format: nil)
        audioPlayer.scheduleFile(file, at: nil)
        try engine.start()
    }
    func play() {
        audioPlayer.play()
    }
    func pause() {
        audioPlayer.pause()
    }
    func stop() {
        audioPlayer.stop()
        engine.stop()
    }
    func setPitch(_ value: Float) {
        pitchControl.pitch = value
    }
    func getCurrentTime() -> Double {
        guard let nodeTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: nodeTime) else { return audioLengthSeconds + 1000.0 }
        
        return (Double(playerTime.sampleTime) + Double(currentPosition)) / playerTime.sampleRate
    }
    
    func seek(to time: Double) {
        guard let audioFile = audioFile else { return }
        guard let nodeTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: nodeTime) else { return }

        currentPosition = playerTime.sampleTime + seekFrame
        
        let offset = AVAudioFramePosition(time * audioSampleRate) // 이동하고 싶은 만큼의 프레임
        seekFrame = currentPosition + offset // 현재 프레임에서 이동하고 싶은 만큼의 프레임을 더한다
        seekFrame = max(seekFrame, 0) // 0보다 작은 경우는 0으로
        seekFrame = min(seekFrame, audioLengthSamples) // 최대 길이보다 크면 최대 길이로
        currentPosition = seekFrame // 현재 프레임 위치를 업데이트한다
        
        let wasPlaying = audioPlayer.isPlaying // 만약 재생중이라면
        audioPlayer.stop()
        if currentPosition < audioLengthSamples {
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            
            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil,
                completionHandler: nil
            )
            if wasPlaying {
                audioPlayer.play()
            }
        }
    }
    
    func skip(forwards: Bool) {
        if forwards {
            seek(to: 5)
        } else {
            seek(to: -5)
        }
    }
    
    func isFinish() -> Bool {
        let currentTime = Float(getCurrentTime().toStringDecimalPoint2) ?? 0.0
        let totalLengthTime = Float(audioLengthSeconds.toStringDecimalPoint2) ?? 0.0
        return currentTime >= totalLengthTime
    }
    
    func changeVolume(_ value: Float) {
        audioPlayer.volume = value
    }
}
