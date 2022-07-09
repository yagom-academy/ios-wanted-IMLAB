//
//  AudioPlayManager.swift
//  VoiceRecorder
//
//  Created by 오국원 on 2022/07/07.
//

import AVFoundation

protocol AudioPlayDelegate: AnyObject {
    
    func updateCurrentTime()
}

final class AudioPlayManager {
    
    weak var delegate: AudioPlayDelegate?
    
    let audioURL: URL
    
    let engine = AVAudioEngine()
    var audioFile: AVAudioFile?
    
    private var needsFileScheduled = true
    
    var unitTimePitch = AVAudioUnitTimePitch()
    let audioPlayer = AVAudioPlayerNode()
    
    var playerProgress: Double = 0
    private var displayLink: CADisplayLink?
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    
    private var currentFrame: AVAudioFramePosition {
        guard
          let lastRenderTime = audioPlayer.lastRenderTime,
          let playerTime = audioPlayer.playerTime(forNodeTime: lastRenderTime)
        else {
            return .zero
        }

        return playerTime.sampleTime
    }
    
    var currentTime: Double = 0 {
        didSet {
            delegate?.updateCurrentTime()
        }
    }
    
    init(audioURL: URL) {
        self.audioURL = audioURL
        setupAudio(audioURL)
        setupDisplayLink()
    }
    
    private func setupAudio(_ url: URL) {
        audioFile = try? AVAudioFile(forReading: url)
        guard let file = audioFile else { return }
        let format = file.processingFormat
        
        audioLengthSamples = file.length
        audioSampleRate = format.sampleRate
        audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
        
        audioFile = file
        
        configureEngine(with: format)
    }
    
    private func configureEngine(with format: AVAudioFormat) {
        engine.attach(audioPlayer)
        engine.attach(unitTimePitch)

        engine.connect(audioPlayer, to: unitTimePitch, format: format)
        engine.connect(unitTimePitch, to: engine.mainMixerNode, format: format)

        engine.prepare()
        
        do {
            try engine.start()
            scheduleAudioFile()
        } catch {
            print("Error starting the player: \(error.localizedDescription)")
        }
    }
    
    private func scheduleAudioFile() {
        guard let file = audioFile, needsFileScheduled else {
            return
        }

        needsFileScheduled = false
        seekFrame = 0

        audioPlayer.scheduleFile(file, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.isPaused = true
    }

    @objc func updateDisplay() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)

        if currentPosition >= audioLengthSamples {
            audioPlayer.stop()

            seekFrame = 0

            displayLink?.isPaused = true
        }

        currentTime = Double(currentPosition) / audioSampleRate
    }
    
    func play() {
        displayLink?.isPaused = false
        audioPlayer.play()
    }
    
    func pause() {
        displayLink?.isPaused = true
        audioPlayer.pause()
    }
    
    func seek(to time: Double) {
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
    
    func controlVolume(to volume: Float) {
        audioPlayer.volume = volume
    }
    
    func changePitch(to pitch: Int) {
        switch pitch {
        case 0:
            unitTimePitch.pitch = 0
        case 1:
            unitTimePitch.pitch = 1300
        default:
            unitTimePitch.pitch = -1300
        }
    }
}
