//
//  AudioManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/07/01.
//

import Foundation
import AVFoundation

class AudioManager {
    
    // - MARK: Property
    
    lazy var audioEngine = AVAudioEngine()
    
    // - MARK: LifeCycle
    
    init() {}
    
    func getAudioFile(filePath: URL) throws -> AVAudioFile {
        
        return try AVAudioFile(forReading: filePath)
    }
    
    func removeEngineNodes() {
        
        audioEngine.attachedNodes.forEach {
            $0.removeTap(onBus: 0)
        }
    }
    
}

// - MARK: Audio Info Methods

extension AudioManager {

    /// 현재 재생중인 audioFile의 전체 길이. float을 Int로 변환하고, string으로 반환
    func getPlayTime(filePath: URL) -> String {
        
        return "\(Int(getPlayTime(filePath: filePath)))"
    }
    
    func getPlayTime(filePath: URL) -> Double {
        
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        let audioLengthSamples = audioFile.length
        let sampleRate = audioFile.processingFormat.sampleRate
        let audioPlayTime = Double(audioLengthSamples) / sampleRate
        
        return audioPlayTime
    }
    
    func getPlayTime(audioFile: AVAudioFile) -> Double {
        
        let audioLengthSamples = audioFile.length
        let sampleRate = audioFile.processingFormat.sampleRate
        let audioPlayTime = Double(audioLengthSamples) / sampleRate
        
        return audioPlayTime
    }
    
    func getChannelData(audioFile: AVAudioFile) -> AVAudioPCMBuffer? {
        
        let capacity = AVAudioFrameCount(audioFile.length)
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                                 frameCapacity: capacity) else {
            return nil
        }
        
        return audioBuffer
    }
    
    func scalePower(power: Float) -> Float {
        
        guard power.isFinite else { return 0 }
        let mindB: Float = -80
        
        if power < mindB {
            return 0
        } else if power >= 1 {
            return 1
        } else {
            return (abs(mindB) - abs(power)) / abs(mindB)
        }
    }
    
}
