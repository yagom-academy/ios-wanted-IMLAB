//
//  SoundManager.swift
//  VoiceRecorder
//
//  Created by 신의연 on 2022/06/29.
//

import Foundation
import AVFoundation
import AVKit

protocol ReceiveSoundManagerStatus {
    func observeAudioPlayerDidFinishPlaying(_ playerNode: AVAudioPlayerNode)
}

class SoundManager: NSObject {
    
    var delegate: ReceiveSoundManagerStatus?
    
    private let engine = AVAudioEngine()
    private lazy var inputNode = engine.inputNode
    private let mixerNode = AVAudioMixerNode()
    
    private let playerNode = AVAudioPlayerNode()
    private let pitchControl = AVAudioUnitTimePitch()
    
    var songLengthSamples: AVAudioFramePosition!
    
    var sampleRateSong: Float = 0
    var lengthSongSeconds: Float = 0
    var startInSongSeconds: Float = 0
    
    var audioFile: AVAudioFile!
    var audioFileManager = AudioFileManager()
    
    override init() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func initializedEngine(url: URL) {
        do {
            let file = try AVAudioFile(forReading: url)
            let fileFormat = file.processingFormat
           
            audioFile = file
            songLengthSamples = audioFile.length
            sampleRateSong = Float(fileFormat.sampleRate)
            lengthSongSeconds = Float(songLengthSamples) / sampleRateSong
            
            configurePlayEngine(format: fileFormat)
            
            playerNode.scheduleFile(file, at: nil) { [self] in
                self.delegate?.observeAudioPlayerDidFinishPlaying(playerNode)
            }
        } catch let error as NSError {
            print("엔진 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
    }
    
    func configureRecordEngine(format: AVAudioFormat) {
        mixerNode.volume = 0
        
        engine.attach(mixerNode)
        engine.connect(inputNode, to: mixerNode, format: format)
    }
    
    func configurePlayEngine(format: AVAudioFormat) {
        engine.attach(playerNode)
        engine.attach(pitchControl)
        
        engine.connect(playerNode, to: pitchControl, format: format)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: format)
        
        engine.prepare()
    }
    
    private func createAudioFile(filePath: URL) throws -> AVAudioFile {
        let format = inputNode.outputFormat(forBus: 0)
        return try AVAudioFile(forWriting: filePath, settings: format.settings)
    }
    
    private func getAudioFile(filePath: URL) throws -> AVAudioFile {
        return try AVAudioFile(forReading: filePath)
    }
    
    func startRecord(filePath: URL) {
        engine.reset()
        
        let format = inputNode.outputFormat(forBus: 0)
        configureRecordEngine(format: format)
        
        do {
            audioFile = try createAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        mixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            do {
                try self.audioFile.write(from: buffer)
            } catch {
                print("[error] : startRecord")
            }
        }
        
        do {
            try engine.start()
        } catch {
            fatalError()
        }
    }
    
    func stopRecord() {
        mixerNode.removeTap(onBus: 0)
        
        engine.stop()
    }
    
    func play() {
        try! engine.start()
        playerNode.play()
    }
    
    func pause() {
        playerNode.pause()
    }
}

extension SoundManager {
    
    // - MARK: playTime
    
    func totalPlayTime(date: String) -> Double {
        let url = audioFileManager.getAudioFilePath(fileName: date)
        do {
            audioFile = try getAudioFile(filePath: url)
        } catch {
            print("[error] : totalPlayTime")
        }
        
        let length = audioFile.length
        let sampleRate = audioFile.processingFormat.sampleRate
        let audioPlayTime = Double(length) / sampleRate
        
        return audioPlayTime
    }
    
    func convertTimeToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        
        return strTime
    }
}
