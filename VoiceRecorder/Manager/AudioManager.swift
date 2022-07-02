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
    private lazy var recordEngine = AVAudioEngine()
    private lazy var audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    private lazy var audioEQFilterParameters = audioEQ.bands[0]
    private lazy var inputNode = recordEngine.inputNode
    private lazy var mixerNode = AVAudioMixerNode()
    lazy var cutOffFrequency: Float = 0
    
    // play properties
    private lazy var seekFrame: AVAudioFramePosition = 0
    private lazy var currentPosition: AVAudioFramePosition = 0
    private lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var changePitchNode = AVAudioUnitTimePitch()
    private lazy var playEngine = AVAudioEngine()
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
        recordEngine.attach(audioEQ)
        recordEngine.attach(mixerNode)
        
        recordEngine.connect(mixerNode, to: audioEQ,
                             format: format)
        recordEngine.connect(inputNode, to: mixerNode,
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
    
    private func configureAudioEngineForRecord() {
        let format = inputNode.outputFormat(forBus: 0)
        prepareRecordEngine(format: format)
        prepareAudioEQNode()
        
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
        recordEngine.reset()
        configureAudioEngineForRecord()
        record(filePath: filePath)
        do {
            try recordEngine.start()
        } catch {
            fatalError()
        }
    }
    
    /// 레코딩 완료
    func stopRecord() {
        recordEngine.stop()
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
        
        let capacity = AVAudioFrameCount(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: capacity) else {
            return nil
        }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            return nil
        }
        guard let channelData = audioBuffer.floatChannelData else {
            return nil
        }
        
        let channels = Int(audioBuffer.format.channelCount)
        let renderSamples = 0..<Int(capacity)
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
        if !playEngine.isRunning {
            playEngine.reset()
            configureAudioEngineForPlay(filePath: fileURL)
            do {
                try playEngine.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        audioPlayerNode.play()
    }
    
    func stopPlay() {
        playEngine.stop()
    }
    
    private func attachPlayNodes() {
        playEngine.attach(audioPlayerNode)
        playEngine.attach(changePitchNode)
    }
    
    private func connectPlayNodes() {
        playEngine.connect(audioPlayerNode, to: changePitchNode, format: nil)
        playEngine.connect(changePitchNode, to: playEngine.mainMixerNode, format: nil)
    }
    
    private func configureAudioEngineForPlay(filePath: URL) {
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        attachPlayNodes()
        connectPlayNodes()
        
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        
        playEngine.prepare()
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
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
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
