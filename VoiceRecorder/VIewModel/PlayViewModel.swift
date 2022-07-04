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

class PlayViewModel {
    private var url: URL
    
    private var audioPlayer = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var audioFormat = AVAudioFormat()
    private var engine = AVAudioEngine()
    private var pitchControl = AVAudioUnitTimePitch()
    
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    
    private var audioSampleRate:Double = 0
    private var audioLengthSeconds: Double = 0
    
    private var needsFileScheduled = true
    
    private var displayLink: CADisplayLink?
    
    @Published var playerProgress: Float = 0
    @Published var playerIsPlaying: Bool = false
    @Published var playerTime: PlayerTime = .zero
    
    init(url: URL) {
        self.url = url
        setupAudioFile()
        setupDisplayLink()
    }
    
    private func setupAudioFile() {
        do {
            let file = try AVAudioFile(forReading: url)
            
            audioFormat = file.processingFormat
            
            audioLengthSamples = file.length
            audioSampleRate = audioFormat.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            
            audioFile = file
            
            setupPlayerTime()
            setupAudioEngine()
        } catch {
            print("AudioFile Error: \(error.localizedDescription)")
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
        } catch {
            print("AudioEngine Error: \(error.localizedDescription)")
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
    
    func pitchControlValueChanged(_ value: Float) {
        pitchControl.pitch = 1200 * value
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
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        
        if currentPosition < audioLengthSamples {
            updateDisplay()
            needsFileScheduled = false
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
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
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition >= audioLengthSamples{
            audioPlayer.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            displayLink?.isPaused = true
            playerIsPlaying = false
        }
        
        setupPlayerTime()
        playerProgress = Float(currentPosition) / Float(audioLengthSamples)
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
