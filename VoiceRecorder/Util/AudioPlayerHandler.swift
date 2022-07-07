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
<<<<<<< HEAD
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioUnitTimePitch: AVAudioUnitTimePitch!
    var audioMixerNode: AVAudioMixerNode!
    var buffer: AVAudioPCMBuffer!
    var playerProgress: Float = 0 // elapsed time
    var audioSampleRate: Double = 0
    var audioLengthSeconds: Double = 0 // total time
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var needsFileScheduled = true
    var isPlaying = false
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = audioPlayerNode.lastRenderTime,
            let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return currentPosition
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
        setUpSession()
    }
    
    func setUpSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let audioPlayer = try AVAudioPlayer(contentsOf: recordFileURL)
            self.audioPlayer = audioPlayer
            self.audioPlayer.prepareToPlay()
            setupAudio()
        } catch let error {
            print("Error : setUpPlayer - \(error)")
        }
    }
    
    func setupAudio() {
        do {
            audioFile = try AVAudioFile(forReading: recordFileURL)
            buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: buffer)
            audioLengthSamples = audioFile.length
            audioSampleRate = audioFile.processingFormat.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            setEngine()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setEngine() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioUnitTimePitch = AVAudioUnitTimePitch()
        audioMixerNode = AVAudioMixerNode()
        
        audioEngine.attach(audioPlayerNode)
<<<<<<< HEAD
        audioEngine.attach(audioUnitTimePitch)
        audioEngine.attach(audioMixerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePitch, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.outputNode, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.mainMixerNode, format: buffer.format)
        
=======
        audioEngine.attach(audioUnitTimePich)
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePich, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePich, to: audioEngine.outputNode, format: audioFile.processingFormat)

        audioPlayerNode.volume = 5.0
>>>>>>> parent of dc7b987 (Merge pull request #15 from JangJuMyeong/iw_1_hoifather)
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        
        do {
            try audioEngine.start()
            scheduleAudioFile()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func changePitch(to pitch: Float) {
        audioUnitTimePich.pitch = pitch
    }
    
    func scheduleAudioFile() {
        needsFileScheduled = false
        seekFrame = 0
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    func playOrPause() {
        isPlaying.toggle()
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.pause()
        } else {
            if needsFileScheduled {
                scheduleAudioFile()
            }
            audioPlayerNode.play()
        }
    }
    
    func seek(to time: Double) {
        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        audioPlayerNode.stop()
        if currentPosition < audioLengthSamples {
            updatePosition()
            needsFileScheduled = false
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            audioPlayerNode.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) {
                self.needsFileScheduled = true
            }
        }
        if isPlaying {
            audioPlayerNode.play()
        }
    }
    
    func updatePosition() {
        currentPosition = currentFrame + seekFrame
    }
    
    func getProgress() -> Float {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
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
