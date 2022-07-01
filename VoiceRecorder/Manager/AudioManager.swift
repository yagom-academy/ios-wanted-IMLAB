//
//  AudioManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/07/01.
//

import Foundation
import AVFoundation
import Accelerate

class AudioManager {
    private var filePath: URL
    private let audioEngine = AVAudioEngine()
    private let audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    private lazy var audioEQFilterParameters = audioEQ.bands[0]
    private lazy var inputNode = audioEngine.inputNode
    private lazy var mixerNode = audioEngine.mainMixerNode
    private let audioPlayerNode = AVAudioPlayerNode()
    var cutOffFrequency: Float = 0
    
    private var audioFile: AVAudioFile!
    
    init(filePath: URL) {
        self.filePath = filePath
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // 노드생성
    private func configureNode() {
        mixerNode.outputVolume = 1
    }
    
    // eq
    private func configureEqFilter() {
        audioEQFilterParameters.filterType = .lowPass
        audioEQFilterParameters.frequency = cutOffFrequency
    }
    
    private func attachNodes() {
        audioEngine.attach(audioEQ)
    }
    
    private func connectNodes() {
        audioEngine.connect(mixerNode, to: audioEQ,
                            format: audioEngine.mainMixerNode.outputFormat(forBus: 0))
        audioEngine.connect(inputNode, to: mixerNode,
                            format: audioEngine.mainMixerNode.outputFormat(forBus: 0))
    }
    
    private func createAudioFile(filePath: URL) throws -> AVAudioFile {
        let inputformat = inputNode.inputFormat(forBus: 0)
        return try AVAudioFile(forWriting: filePath, settings: inputformat.settings, commonFormat: .pcmFormatInt32, interleaved: true)
    }
    
    private func configureAudioEngine() {
        configureNode()
        configureEqFilter()
        attachNodes()
        connectNodes()
        
        let format = audioEQ.outputFormat(forBus: 0)
        guard let audioFile = try? createAudioFile(filePath: filePath) else {
            fatalError()
        }
        
        audioEQ.removeTap(onBus: 0)
        audioEQ.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            guard let self = self else { return }
            let bufferData = self.calculatorBufferGraphData(buffer: buffer)
            do {
                try audioFile.write(from: buffer)
            } catch {
                fatalError()
            }
        }
    }
    
    private func calculatorBufferGraphData(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataValue = channelData.pointee
        let channelDataArrayValue = stride(from: 0,
                                           to: Int(buffer.stride),
                                           by: buffer.stride)
            .map { channelDataValue[$0] }
        
        let rms = sqrt(channelDataArrayValue.map { return $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        let meterLevel = scalePower(power: avgPower)
        
        return meterLevel
    }
    
    private func scalePower(power: Float) -> Float {
        guard power.isFinite else { return 0 }
        let minDB: Float = -80
        
        if power < minDB {
            return 0
        } else if power >= 1 {
            return 1
        } else {
            return (abs(minDB) - abs(power)) / abs(minDB)
        }
    }
    
    func startRecord() {
        audioEngine.reset()
        configureAudioEngine()
        do {
            try audioEngine.start()
        } catch {
            fatalError()
        }
    }
    
    /// 레코딩 완료
    func stopRecord() {
        audioEngine.stop()
    }
    
    /// 현재 재생중인 audioFile의 전체 길이. float을 Int로 변환하고, string으로 반환
    func getPlayTime() -> String {
        
        let audioLengthSamples = audioFile.length
        let sampleRate = audioFile.processingFormat.sampleRate
        let audioPlayTime = Double(audioLengthSamples) / sampleRate
        
        return "\(Int(audioPlayTime))"
    }
}
