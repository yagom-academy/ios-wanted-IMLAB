//
//  AudioPlayerHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation
import Accelerate
import MediaPlayer

class AudioPlayerHandler {
    
    private var localFileHandler: LocalFileProtocol
    private var timeHandler: TimeProtocol
    
    private var recordFileURL: URL!
    private var audioFile: AVAudioFile!
    private var audioEngine: AVAudioEngine!
    private var audioPlayerNode: AVAudioPlayerNode!
    private var audioUnitTimePitch: AVAudioUnitTimePitch!
    private var audioMixerNode: AVAudioMixerNode!
    private var buffer: AVAudioPCMBuffer!
    private var displayLink: CADisplayLink!
    private var seekFrame: AVAudioFramePosition = 0
    private var currentFramePosition: AVAudioFramePosition = 0
    private var audioFileFrameLength: AVAudioFramePosition = 0
    private var audioFileSampleRate: Double = 0
    private var audioFileTotalPlayTime: Double = 0
    private var needsFileScheduled = true
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = audioPlayerNode.lastRenderTime,
            let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        return playerTime.sampleTime
    }
    
    var progress: Float = 0
    var currentPlayTime = "00:00"
    var isPlaying = false
    var isfinished = false
    
    init(localFileHandler: LocalFileProtocol, timeHandler: TimeProtocol) {
        self.localFileHandler = localFileHandler
        self.timeHandler = timeHandler
        setUpDisplayLink()
    }
    
    func selectPlayFile(_ fileName: String?,_ isRecordFile: Bool = false) {
        if fileName == nil {
            let latestRecordFileName = localFileHandler.getLatestFileName()
            let latestRecordFileURL = localFileHandler.localFileURL.appendingPathComponent(latestRecordFileName)
            self.recordFileURL = latestRecordFileURL
        } else {
            guard let playFileName = fileName else { return }
            var selectedFileURL: URL?
            if isRecordFile {
                selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("\(playFileName)")
            } else {
                selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("voiceRecords_\(playFileName)")
            }
            self.recordFileURL = selectedFileURL
        }
        setUpSession()
    }
    
    private func setUpSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            setUpAudio()
        } catch let error {
            print("Error : setUpPlayer - \(error)")
        }
    }
    
    private func setUpAudio() {
        do {
            audioFile = try AVAudioFile(forReading: recordFileURL)
            buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                      frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: buffer)
            readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
            audioFileFrameLength = audioFile.length
            audioFileSampleRate = audioFile.processingFormat.sampleRate
            audioFileTotalPlayTime = Double(audioFileFrameLength) / audioFileSampleRate
            setUpEngine()
        } catch {
            print("Error - setupAudio \(error)")
        }
    }
    
    private func setUpEngine() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioUnitTimePitch = AVAudioUnitTimePitch()
        audioMixerNode = AVAudioMixerNode()
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(audioUnitTimePitch)
        audioEngine.attach(audioMixerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioUnitTimePitch, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.outputNode, format: audioFile.processingFormat)
        audioEngine.connect(audioUnitTimePitch, to: audioEngine.mainMixerNode, format: buffer.format)
        
        audioPlayerNode.volume = 5.0
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        
        do {
            try audioEngine.start()
            scheduleAudioFile()
        } catch {
            print("Error - setEngine \(error)")
        }
    }

    private func scheduleAudioFile() {
        needsFileScheduled = false
        seekFrame = 0
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    private func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(updatePlayProgress))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    @objc private func updatePlayProgress() {
        currentFramePosition = currentFrame + seekFrame
        currentFramePosition = max(currentFramePosition, 0)
        currentFramePosition = min(currentFramePosition, audioFileFrameLength)
        
        if currentFramePosition >= audioFileFrameLength {
            audioPlayerNode.stop()
            isfinished = true
            seekFrame = 0
            if audioPlayerNode.isPlaying {
                currentFramePosition = 0
            } else {
                currentFramePosition = audioFileFrameLength
            }
            
            isPlaying = false
            displayLink?.isPaused = true
        }
        progress = Float(Double(currentFramePosition) / Double(audioFileFrameLength))
        
        let time = Double(currentFramePosition) / audioFileSampleRate
        let convertedTime = updateTimer(time)
        currentPlayTime = convertedTime
    }
    
    func changePitch(to pitch: Float) {
        audioUnitTimePitch.pitch = pitch
    }
    
    func changeVolume(to volume: Float) {
        audioPlayerNode.volume = volume
    }
    
    func play() {
        isPlaying.toggle()
        if isfinished {
            isfinished.toggle()
        }
        displayLink?.isPaused = false
        if needsFileScheduled {
            scheduleAudioFile()
        }
        audioPlayerNode.play()
    }
    
    func pause() {
        isPlaying.toggle()
        
        displayLink?.isPaused = true
        audioPlayerNode.pause()
    }
    
    func stop() {
        displayLink?.isPaused = true
        audioPlayerNode.stop()
        audioEngine.stop()
    }
    
    func skip(to time: Double) {
        let offset = AVAudioFramePosition(time * audioFileSampleRate)
        seekFrame = currentFramePosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioFileFrameLength)
        
        let oneOffset = AVAudioFramePosition(audioFileSampleRate)
        if seekFrame + oneOffset >= audioFileFrameLength {
            seekFrame = audioFileFrameLength
        } else if seekFrame - oneOffset <= 0 {
            seekFrame = 0
        }
        
        currentFramePosition = seekFrame
        audioPlayerNode.stop()
        
        if currentFramePosition <= audioFileFrameLength {
            updatePlayProgress()
            needsFileScheduled = false
            let frameCount = AVAudioFrameCount(audioFileFrameLength - seekFrame)
            audioPlayerNode.scheduleSegment(audioFile,
                                            startingFrame: seekFrame,
                                            frameCount: frameCount,
                                            at: nil) {
                self.needsFileScheduled = true
            }
            if isPlaying {
                audioPlayerNode.play()
            }
        }
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return timeHandler.convertNSTimeToString(time)
    }
}

