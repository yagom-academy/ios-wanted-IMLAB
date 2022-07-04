//
//  AudioManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/07/01.
//

import Foundation
import AVFoundation
import Accelerate

enum AudioPitchMode {
    case baby, basic, grandFather
    
    var pitchValue: Float {
        switch self {
        case .baby:
            return 1200
        case .basic:
            return 0
        case .grandFather:
            return -1200
        }
    }
}

class AudioManager {
    
    // - MARK: Property
    
    // recording properties
    private lazy var audioEngine = AVAudioEngine()
    private lazy var audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    private lazy var audioEQFilterParameters = audioEQ.bands[0]
    private lazy var inputNode = audioEngine.inputNode
    private lazy var mixerNode = AVAudioMixerNode()
    lazy var cutOffFrequency: Float = 0 // 추후 제거할 property
    
    // play properties
    private lazy var seekFrame: AVAudioFramePosition = 0
    private lazy var currentPosition: AVAudioFramePosition = 0
    private lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var changePitchNode = AVAudioUnitTimePitch()

    lazy var pitchMode: AudioPitchMode = .basic {
        didSet {
            changePitchNode.pitch = pitchMode.pitchValue
        }
    }
    
    // - MARK: LifeCycle
    
    init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
            try session.setActive(true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createAudioFile(filePath: URL) throws -> AVAudioFile {
        let inputformat = inputNode.outputFormat(forBus: 0)
        return try AVAudioFile(forWriting: filePath, settings: inputformat.settings)
    }
    
    private func getAudioFile(filePath: URL) throws -> AVAudioFile {
        return try AVAudioFile(forReading: filePath)
    }
    
    // - MARK: Audio Record Methods
    
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
        audioEQFilterParameters.frequency = cutOffFrequency
        audioEQFilterParameters.bandwidth = 5.0
        audioEQFilterParameters.gain = 15
        audioEQFilterParameters.bypass = false
        audioEQ.bypass = false
    }
    
    private func record(filePath: URL) {
        let format = inputNode.outputFormat(forBus: 0)
        
        let audioFile: AVAudioFile!
        do {
            audioFile = try createAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        audioEQ.removeTap(onBus: 0)
        audioEQ.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            guard let self = self else { return }
            let bufferData = self.calculatorBufferGraphData(buffer: buffer)
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
    }
    
}

extension AudioManager {
    
    // - MARK: Audio Info Methods
    
    /// 현재 재생중인 audioFile의 전체 길이. float을 Int로 변환하고, string으로 반환
    func getPlayTime(filePath: URL) -> String {
        let audioFile: AVAudioFile
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        let audioLengthSamples = audioFile.length
        let sampleRate = audioFile.processingFormat.sampleRate
        let audioPlayTime = Double(audioLengthSamples) / sampleRate
        
        return "\(Int(audioPlayTime))"
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
    
    /// audiofile을 읽어 한번에 data를 가져오는 method. width는 waveView의 width이다. nil 값이 나온 것은 bufferData를 읽어오는데 실패한 것
    func calculatorBufferGraphData(width: CGFloat, filePath: URL) -> [Float]? {
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        guard let audioBuffer = getChannelData(audioFile: audioFile),
              let channelData = audioBuffer.floatChannelData else {
            return nil
        }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            return nil
        }
        
        let channels = Int(audioBuffer.format.channelCount)
        let renderSamples = 0..<Int(audioFile.length)
        let samplePerPoint = renderSamples.count / Int(width)
        
        var arr = [Float]()
        
        for point in 0..<Int(width) {
            for channel in 0..<channels {
                let pointer = channelData[channel].advanced(by: renderSamples.lowerBound + Int((point * samplePerPoint)))
                let stride = vDSP_Stride(audioBuffer.stride)
                let length = vDSP_Length(samplePerPoint)
                
                var minValue: Float = 0
                var maxValue: Float = 0
                vDSP_minv(pointer, stride, &minValue, length)
                vDSP_maxv(pointer, stride, &maxValue, length)
                
                let rms = (sqrt(minValue * minValue) + sqrt(maxValue * maxValue)) / 2
                let avgPower = 20 * log10(rms)
                let meterLevel = self.scalePower(power: avgPower)
                arr.append(meterLevel)
            }
        }
        
        return arr
    }
    
    private func getChannelData(audioFile: AVAudioFile) -> AVAudioPCMBuffer? {
        
        let capacity = AVAudioFrameCount(audioFile.length)
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                                 frameCapacity: capacity) else {
            return nil
        }
        
        return audioBuffer
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
}

extension AudioManager {
    
    // - MARK: Audio Play Method
    
    func startPlay(fileURL: URL) {
        if !audioEngine.isRunning {
            audioEngine.reset()
            
            preparePlayEngine()
            preparePlay(filePath: fileURL)
            
            do {
                try audioEngine.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        audioPlayerNode.play()
    }
    
    func stopPlay() {
        audioEngine.stop()
        seekFrame = 0
        currentPosition = 0
    }
    
    private func preparePlayEngine() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(changePitchNode)
        audioEngine.connect(audioPlayerNode, to: changePitchNode, format: nil)
        audioEngine.connect(changePitchNode, to: audioEngine.mainMixerNode, format: nil)
        
    }
    
    private func preparePlay(filePath: URL) {
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            NotificationCenter.default.post(name: .audioPlaybackTimeIsOver, object: nil, userInfo: nil)
        }
        
        audioEngine.prepare()
    }
    
    private func validateFrameEdge(with frame: AVAudioFramePosition, limit: AVAudioFramePosition) -> AVAudioFramePosition {
        var frame = frame
        frame = max(frame, 0)
        frame = min(frame, limit)
        
        return frame
    }
    
    /// second는 이동할 시간, 음수도 가능.
    func skip(for second: Double, filePath: URL) {
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        
        let offset = AVAudioFramePosition(second * audioFile.processingFormat.sampleRate)
        let audioLengthSamples = audioFile.length
        
        guard let lastRenderTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime) else {
            return
        }
        
        currentPosition = playerTime.sampleTime + seekFrame
        currentPosition = validateFrameEdge(with: currentPosition,
                                            limit: audioLengthSamples)
        
        seekFrame = validateFrameEdge(with: currentPosition + offset,
                                      limit: audioLengthSamples)
        
        currentPosition = seekFrame
        
        audioPlayerNode.stop()
        if currentPosition < audioLengthSamples {
            let frameCount = AVAudioFrameCount( audioLengthSamples - seekFrame)
            
            audioPlayerNode
                .scheduleSegment(audioFile,
                                 startingFrame: currentPosition,
                                 frameCount: frameCount,
                                 at: nil
                )
        }
        
        audioPlayerNode.play()
    }
    
    func controlVolume(newValue: Float) {
        if newValue >= 1 {
            audioPlayerNode.volume = 1
        } else if newValue <= 0 {
            audioPlayerNode.volume = 0
        } else {
            audioPlayerNode.volume = newValue
        }
    }
    
}
