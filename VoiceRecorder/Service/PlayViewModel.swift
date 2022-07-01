//
//  PlayAudioEngine.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/30.
//

import Foundation
import AVFAudio
import QuartzCore

class PlayViewModel {
    var url: URL
    
    private var audioPlayer = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var engine = AVAudioEngine()
    private var pitchControl = AVAudioUnitTimePitch()
    
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var audioSampleRate:Double = 0
    private var audioLengthSeconds: Double = 0
    private var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime) else{
            return 0
        }
        return playerTime.sampleTime
    }
    
    var playerProgress: Observable<Float> = Observable(0)
    
    var displayLink: CADisplayLink?
    
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    
    var format = AVAudioFormat()
    
    init(url: URL) {
        self.url = url
        self.setup()
        self.setupDisplayLink()
    }
    
    //    deinit {
    //        print(#function)
    //        self.displayLink?.invalidate()
    //    }
    
    private func setup() {
        do {
            let file = try AVAudioFile(forReading: url)
            
            format = file.processingFormat
            
            self.audioLengthSamples = file.length
            self.audioSampleRate = format.sampleRate
            self.audioLengthSeconds = Double(self.audioLengthSamples) / self.audioSampleRate
            
            self.audioFile = file
            
            self.setupAudioEngine()
        } catch {
            print("AudioFile Error: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioEngine() {
        self.engine.attach(self.audioPlayer)
        self.engine.attach(self.pitchControl)
        
        self.engine.connect(self.audioPlayer, to: self.pitchControl, format: format)
        self.engine.connect(self.pitchControl, to: self.engine.mainMixerNode, format: format)
        
        do {
            try self.engine.start()
            
            guard let audioFile = self.audioFile else { return }
            self.audioPlayer.scheduleFile(audioFile, at: nil)
            
        } catch {
            print("AudioEngine Error: \(error.localizedDescription)")
        }
    }
    
    func togglePlaying(completion: @escaping(Bool) -> Void) {
        if self.audioPlayer.isPlaying {
            self.audioPlayer.pause()
            self.displayLink?.isPaused = true
        } else {
            self.audioPlayer.play()
            self.displayLink?.isPaused = false
        }
        completion(true)
    }
    
    func volumeChanged(_ value: Float) {
        self.audioPlayer.volume = value
    }
    
    func pitchControlValueChanged(_ value: Float) {
        self.pitchControl.pitch = 1200 * value
    }
    
    //Skip
    func skip(forwards:Bool){
        let timeToSeek:Double
        
        if forwards{
            timeToSeek = 5
        } else {
            timeToSeek = -5
        }
        
        seek(to: timeToSeek)
    }
    
    //현재 위치 + 시간 위치로 이동후 실행 메소드
    func seek(to time:Double){
        guard let audioFile = audioFile else {
            return
        }
        
        let offset = AVAudioFramePosition(time * audioSampleRate)
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        
        if currentPosition < audioLengthSamples{
            updateDisplay()
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            audioPlayer.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) {
            }
            
            if wasPlaying{
                audioPlayer.play()
            }
        }
    }
    
    // 현재 시간 + 5초 계산 메소드
    @objc private func updateDisplay() {
        print(currentFrame)
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition >= audioLengthSamples{
            audioPlayer.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            displayLink?.isPaused = true
        }
        
//        let time = Double(currentPosition) / audioSampleRate
//        let remainTime = audioLengthSeconds - time
//        print("All second \(audioLengthSeconds)")
//        print("Remain time \(audioLengthSeconds - time)")
        
        playerProgress.value = Float(currentPosition) / Float(audioLengthSamples)
//        print(currentPosition, currentFrame, audioLengthSamples)
//        playerProgress.value = Float(time) / Float(audioLengthSeconds)
//        print(playerProgress.value)
    }
    
    // 5초 오류 발생
    // 시간이 흐르면서 변하지가 않고 원래 초가 고정되어 있음
    
    func setupDisplayLink() {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            <#code#>
//        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.isPaused = true
    }
}
