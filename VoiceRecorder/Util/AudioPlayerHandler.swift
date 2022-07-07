//
//  AudioPlayerHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayerHandler {
    
    var audioPlayer = AVAudioPlayer()
    var localFileHandler: LocalFileProtocol
    var updateTimeInterval: UpdateTimer
    var recordFileURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioUnitTimePitch: AVAudioUnitTimePitch!
    var playerProgress: Float = 0 // elapsed time
    var audioSampleRate: Double = 0
    var audioLengthSeconds: Double = 0 // total time
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var needsFileScheduled = true
    var isPlaying = true
    private var currentFrame: AVAudioFramePosition {
      guard
        let lastRenderTime = audioPlayerNode.lastRenderTime,
        let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
      else {
        return 0
      }

      return playerTime.sampleTime
    }
    
    init(handler: LocalFileProtocol, updateTimeInterval: UpdateTimer) {
        self.localFileHandler = handler
        self.updateTimeInterval = updateTimeInterval
    }
    
    func selectPlayFile(_ fileName: String?) {
        if fileName == nil {
            let latestRecordFileName = localFileHandler.getLatestFileName()
            let latestRecordFileURL = localFileHandler.localFileURL.appendingPathComponent(latestRecordFileName)
            self.recordFileURL = latestRecordFileURL
        } else {
            guard let playFileName = fileName else { return }
            let selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("voiceRecords_\(playFileName)")
            self.recordFileURL = selectedFileURL
        }
        setPlayer()
    }
    
    func prepareToPlay() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            let audioPlayer = try AVAudioPlayer(contentsOf: recordFileURL)
            self.audioPlayer = audioPlayer
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.volume = 5.0
        } catch let error {
            print("Error : setUpPlayer - \(error)")
        }
    }
    
    func setPlayer() {
        do {
            let file = try AVAudioFile(forReading: recordFileURL)
            let format = file.processingFormat
            
            audioLengthSamples = file.length
            audioSampleRate = format.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            
            audioFile = file
            setEngine(with: format)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func setEngine(with format: AVAudioFormat) {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioUnitTimePitch = AVAudioUnitTimePitch()
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(audioUnitTimePitch)
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePitch, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        do {
            try audioEngine.start()
            seekFrame = 0
            scheduleAudioFile()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func changePitch(to pitch: Float) {
        audioUnitTimePitch.pitch = pitch
    }
    
    func scheduleAudioFile() {
        needsFileScheduled = false
        seekFrame = 0
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    func play() {
        isPlaying = true
        if needsFileScheduled {
            scheduleAudioFile()
        }
        audioPlayerNode.play()
    }
    
    func pause() {
        isPlaying = false
        audioPlayerNode.pause()
    }
    
    func stop() {
        isPlaying = false
        audioPlayerNode.stop()
    }
    
    func seek(to time: Double) {
        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        audioPlayerNode.stop()
        
        if currentPosition < audioLengthSamples {
            
            currentProgress()
            needsFileScheduled = false
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            audioPlayerNode.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) {
                self.needsFileScheduled = true
            }
        }
        audioPlayerNode.play()
    }
    
    func currentProgress() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        playerProgress = Float(currentPosition) / Float(audioLengthSamples)
    }
    
    func getCurrentProgress() -> Float {
        currentPosition = currentFrame + seekFrame
        if currentPosition >= audioLengthSamples {
            audioPlayerNode.stop()
            isPlaying = false
            seekFrame = 0
            currentPosition = 0
        }
        playerProgress = Float(currentPosition) / Float(audioLengthSamples)
        return playerProgress
    }
    
    func getCurrentPlayTime() -> String {
        let time = Double(currentPosition) / audioSampleRate
        let convertedTime = updateTimer(time)
        return convertedTime
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }

}
