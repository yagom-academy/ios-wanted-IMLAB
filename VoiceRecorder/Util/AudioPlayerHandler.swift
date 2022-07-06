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
    var buffer: AVAudioPCMBuffer!
    var audioFile: AVAudioFile!
    var audioEngine = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    let audioUnitTimePich = AVAudioUnitTimePitch()
    
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
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
    
    func setEngine() {
        do {
            audioFile = try AVAudioFile(forReading: recordFileURL)
            buffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(audioFile!.length))
            try! audioFile!.read(into: buffer)
        } catch {
            print(error.localizedDescription)
        }
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(audioUnitTimePich)
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePich, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePich, to: audioEngine.outputNode, format: audioFile.processingFormat)

        audioPlayerNode.volume = 5.0
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func changePitch(to pitch: Float) {
        audioUnitTimePich.pitch = pitch
    }
//
//    private func seek(to time: Double) {
//      guard let audioFile = audioFile else {
//        return
//      }
//
//      let offset = AVAudioFramePosition(time * audioSampleRate)
//      seekFrame = currentPosition + offset
//      seekFrame = max(seekFrame, 0)
//      seekFrame = min(seekFrame, audioLengthSamples)
//      currentPosition = seekFrame
//
//      let wasPlaying = audioPlayerNode.isPlaying
//        audioPlayerNode.stop()
//
//      if currentPosition < audioLengthSamples {
//        updateDisplay()
//        needsFileScheduled = false
//
//        let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
//          audioPlayerNode.scheduleSegment(
//          audioFile,
//          startingFrame: seekFrame,
//          frameCount: frameCount,
//          at: nil
//        ) {
//          self.needsFileScheduled = true
//        }
//
//        if wasPlaying {
//            audioPlayerNode.play()
//        }
//      }
//    }
//
//    @objc private func updateDisplay() {
//      currentPosition = currentFrame + seekFrame
//      currentPosition = max(currentPosition, 0)
//      currentPosition = min(currentPosition, audioLengthSamples)
//
//      if currentPosition >= audioLengthSamples {
//        audioPlayerNode.stop()
//
//        seekFrame = 0
//        currentPosition = 0
//
//        isPlaying = false
//        displayLink?.isPaused = true
//      }
//
////      playerProgress = Double(currentPosition) / Double(audioLengthSamples)
//
//      let time = Double(currentPosition) / audioSampleRate
//      playerTime = PlayerTime(
//        elapsedTime: time,
//        remainingTime: audioLengthSeconds - time)
//    }
}
