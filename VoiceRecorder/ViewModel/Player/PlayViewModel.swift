//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by rae on 2022/06/30.
//

import Foundation
import AVFAudio
import QuartzCore
import Combine

final class PlayViewModel {
    private var url: URL
        
    private var audioPlayer: AVAudioPlayerNode = {
        let audioPlayer = AVAudioPlayerNode()
        audioPlayer.volume = Constants.VolumeSliderSize.half
        return audioPlayer
    }()
    private var audioFile: AVAudioFile?
    private var audioFormat = AVAudioFormat()
    private var engine = AVAudioEngine()
    private var pitchControl = AVAudioUnitTimePitch()
    
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLength: AVAudioFramePosition = 0
    private var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0
    
    private var needsFileScheduled = true
    
    private var displayLink: CADisplayLink?
    
    @Published var playerProgress: Float = 0
    @Published var playerIsReady = false
    @Published var playerIsPlaying = false
    @Published var playerTime: PlayerTime = .zero
    @Published var isError = false
    
    init(url: URL) {
        self.url = url
        setupAudioFile()
        setupDisplayLink()
    }
    
    private func setupAudioFile() {
        do {
            let file = try AVAudioFile(forReading: url)
            
            audioFormat = file.processingFormat
            
            audioLength = file.length
            audioSampleRate = audioFormat.sampleRate
            audioLengthSeconds = Double(audioLength) / audioSampleRate
            
            audioFile = file
            
            setupAudioEngine()
        } catch {
            debugPrint("AudioFile Error: \(error.localizedDescription)")
            isError = true
        }
    }
    
    private func setupAudioEngine() {
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        
        engine.connect(audioPlayer, to: pitchControl, format: audioFormat)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: audioFormat)
        
        do {
            try engine.start()
            
            scheduleAudioFile()
            setupPlayerTime()
            playerIsReady = true
        } catch {
            debugPrint("AudioEngine Error: \(error.localizedDescription)")
            isError = true
        }
    }
    
    private func scheduleAudioFile() {
        guard let audioFile = audioFile, needsFileScheduled else {
            return
        }
        
        needsFileScheduled = false
        seekFrame = 0
        
        audioPlayer.scheduleFile(audioFile, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    func togglePlaying() {
        if playerIsPlaying {
            playerIsPlaying = false
            displayLink?.isPaused = true
            audioPlayer.pause()
        } else {
            playerIsPlaying = true
            displayLink?.isPaused = false
            
            if needsFileScheduled {
                scheduleAudioFile()
            }
            audioPlayer.play()
        }
    }
    
    func volumeChanged(_ value: Float) {
        audioPlayer.volume = value
    }
    
    func pitchControlValueChanged(_ index: Int) {
        let pitches: [Float] = [0, 0.5, -0.5]
        pitchControl.pitch = 1200 * pitches[index]
    }
    
    func skip(forwards: Bool) {
        let timeToSeek: Double = forwards ? 5 : -5
        seek(to: timeToSeek)
    }
    
    private func seek(to time:Double){
        guard let audioFile = audioFile else {
            return
        }
        
        let offset = AVAudioFramePosition(time * audioSampleRate)
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLength)
        currentPosition = seekFrame
        
        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        
        if currentPosition < audioLength {
            updateDisplay()
            needsFileScheduled = false
            
            let frameCount = AVAudioFrameCount(audioLength - seekFrame)
            audioPlayer.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) {
                self.needsFileScheduled = true
            }
            
            if wasPlaying {
                audioPlayer.play()
            }
        }
    }
    
    @objc private func updateDisplay() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLength)
        
        if currentPosition >= audioLength {
            audioPlayer.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            displayLink?.isPaused = true
            playerIsPlaying = false
        }
        
        setupPlayerTime()
        playerProgress = Float(currentPosition) / Float(audioLength)
    }
    
    private func setupPlayerTime() {
        let time = Double(currentPosition) / audioSampleRate
        playerTime = PlayerTime(elapsedTime: time, remainingTime: audioLengthSeconds - time)
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.isPaused = true
    }
    
    func allStop() {
        audioPlayer.stop()
        engine.stop()
        displayLink?.invalidate()
    }
}
