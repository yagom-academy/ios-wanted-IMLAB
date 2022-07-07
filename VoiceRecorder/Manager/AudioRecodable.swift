//
//  AudioRecodable.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/07/07.
//

import Foundation
import AVFoundation

protocol AudioBufferLiveDataDelegate: AnyObject {
    
    func communicationBufferData(bufferData: Float)
}

protocol AudioRecodable: AudioManager {
    
    var delegate: AudioBufferLiveDataDelegate? { get set }
    var cutOffFrequency: Float { get set }
    
    func startRecord(filePath: URL)
    func stopRecord()
    
}

class DefaultAudioRecoder: AudioManager, AudioRecodable {
    
    // MARK: - Properties
    private lazy var audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    private lazy var audioEQFilterParameters = audioEQ.bands[0]
    private lazy var inputNode = audioEngine.inputNode
    private lazy var mixerNode = AVAudioMixerNode()
    
    weak var delegate: AudioBufferLiveDataDelegate?
    
    lazy var cutOffFrequency: Float = 1 {
        didSet {
            
            let sampleRate = inputNode.outputFormat(forBus: 0).sampleRate
            let sampleRateUnit = Float(sampleRate / 2 / 10)
            
            audioEQFilterParameters.frequency = sampleRateUnit * cutOffFrequency + 20
        }
    }
    
    // MARK: - Record Prepare Methods
    
    private func createAudioFile(filePath: URL) throws -> AVAudioFile {
        
        let inputformat = inputNode.outputFormat(forBus: 0)
        return try AVAudioFile(forWriting: filePath, settings: inputformat.settings)
    }
    
    private func prepareRecordEngine(format: AVAudioFormat) {
        
        audioEngine.attach(audioEQ)
        audioEngine.attach(mixerNode)
        
        audioEngine.connect(mixerNode, to: audioEQ,
                            format: format)
        audioEngine.connect(inputNode, to: mixerNode,
                            format: format)
    }
    
    private func prepareAudioEQNode() {
        
        audioEQFilterParameters.filterType = .lowPass
        cutOffFrequency = cutOffFrequency
        audioEQFilterParameters.bandwidth = 5.0
        audioEQFilterParameters.gain = 15
        audioEQFilterParameters.bypass = false
        audioEQ.bypass = false
    }
    
    // MARK: - Record Methods
    
    private func record(filePath: URL) {
        
        let format = inputNode.outputFormat(forBus: 0)
        let audioFile: AVAudioFile
        
        do {
            audioFile = try createAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        audioEQ.removeTap(onBus: 0)
        audioEQ.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            
            guard let self = self else { return }
            let bufferData = self.calculateBufferGraphData(buffer: buffer)
            self.delegate?.communicationBufferData(bufferData: bufferData)
            
            do {
                try audioFile.write(from: buffer)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func startRecord(filePath: URL) {
        
        audioEngine.reset()
        
        let format = inputNode.outputFormat(forBus: 0)
        prepareRecordEngine(format: format)
        prepareAudioEQNode()
        record(filePath: filePath)
        
        do {
            try audioEngine.start()
        } catch {
            fatalError()
        }
    }
    
    /// 레코딩 완료
    func stopRecord() {
        
        audioEngine.stop()
        removeEngineNodes()
    }
    
    // MARK: - Audio Infomation Methods
    
    private func calculateBufferGraphData(buffer: AVAudioPCMBuffer) -> Float {
        
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
    
}
