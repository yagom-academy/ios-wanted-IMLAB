//
//  AudioPlayable.swift
//  VoiceRecorder
//
//  Created by 이다훈 on 2022/07/07.
//

import Foundation
import AVFoundation
import Accelerate

protocol PlaybackTimeTrackerable: AnyObject {
    
    func trackPlaybackTime(with ratio: Float)
}

protocol AudioPlayable: AudioManager {
    
    var pitchMode: AudioPitchMode { get set }
    var delegate: PlaybackTimeTrackerable? { get set}
    
    func start(fileURL: URL)
    func stop()
    func pause()
    func skip(for second: Double, filePath: URL)
    func controlVolume(newValue: Float)
    func calculateBufferGraphData(width: CGFloat, filePath: URL) -> [Float]?
}

enum AudioPitchMode: String, CaseIterable {
    
    case basic = "일반 목소리"
    case baby = "아기 목소리"
    case grandFather = "할아버지 목소리"
    
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

class DefaultAudioPlayer: AudioManager, AudioPlayable {
    
    // MARK: - Properties
    
    private lazy var seekFrame: AVAudioFramePosition = 0
    private lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var changePitchNode = AVAudioUnitTimePitch()
    
    private var isSkip = false
    lazy var pitchMode: AudioPitchMode = .basic {
        didSet {
            changePitchNode.pitch = pitchMode.pitchValue
        }
    }
    weak var delegate: PlaybackTimeTrackerable?
    
    // MARK: - Play Prepare Methods
    
    private func prepareEngine(_ filePath: URL) {
        
        var audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(changePitchNode)
        
        let format = audioPlayerNode.outputFormat(forBus: 0)
        let customFormat = AVAudioFormat(commonFormat: format.commonFormat, sampleRate: audioFile.fileFormat.sampleRate, channels: format.channelCount, interleaved: false)

        audioEngine.connect(audioPlayerNode, to: changePitchNode, format: customFormat)
        audioEngine.connect(changePitchNode, to: audioEngine.mainMixerNode, format: customFormat)
    }
    
    private func preparePlay(filePath: URL) {
        
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        
        audioPlayerNode.installTap(onBus: 0, bufferSize: 1024, format: audioPlayerNode.outputFormat(forBus: 0)) { [unowned self] buffer, time in
            
            guard let framePosition = getCurrentFramePosition(nodeTime: time, audioFile: audioFile, moveOffset: 0) else {
                return
            }
            
            let currentTime = Double(framePosition) / Double(time.sampleRate)
            let wholeTime: Double = getPlayTime(audioFile: audioFile)
            let ratio = Float(currentTime / wholeTime)
            
            delegate?.trackPlaybackTime(with: ratio)
            
            if ratio >= 1 {
                validateStopPlayBack(isSkip: isSkip)
            }
        }
        
        audioEngine.prepare()
    }
    
    // MARK: - Play methods
    
    func start(fileURL: URL) {
        
        if !audioEngine.isRunning {
            audioEngine.reset()
            prepareEngine(fileURL)
            preparePlay(filePath: fileURL)
            
            do {
                try audioEngine.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        audioPlayerNode.play()
    }
    
    func stop() {
        
        audioEngine.stop()
        seekFrame = 0
        removeEngineNodes()
    }
    
    func pause() {
        
        audioPlayerNode.pause()
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
              let movedFrame = getCurrentFramePosition(nodeTime: lastRenderTime,
                                                       audioFile: audioFile,
                                                       moveOffset: offset)
        else {
            return
        }
        
        seekFrame = movedFrame
        
        isSkip = true
        audioPlayerNode.stop()
        
        if seekFrame < audioLengthSamples {
            let frameCount = AVAudioFrameCount( audioLengthSamples - seekFrame)
            
            audioPlayerNode
                .scheduleSegment(audioFile,
                                 startingFrame: seekFrame,
                                 frameCount: frameCount,
                                 at: nil
                )
        }
        
        isSkip = false
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
    
    private func validateStopPlayBack(isSkip: Bool) {
        
        if !isSkip {
            NotificationCenter.default.post(name: .audioPlaybackTimeIsOver, object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Audio Infomation Methods
    
    private func validateFrameEdge(with frame: AVAudioFramePosition, limit: AVAudioFramePosition) -> AVAudioFramePosition {
        
        var frame = frame
        frame = max(frame, 0)
        frame = min(frame, limit)
        
        return frame
    }
    
    /// audiofile을 읽어 한번에 data를 가져오는 method. width는 waveView의 width이다. nil 값이 나온 것은 bufferData를 읽어오는데 실패한 것
    func calculateBufferGraphData(width: CGFloat, filePath: URL) -> [Float]? {
        let audioFile: AVAudioFile
        
        do {
            audioFile = try getAudioFile(filePath: filePath)
        } catch {
            fatalError()
        }
        
        guard let audioPCMBuffer = getChannelData(audioFile: audioFile),
              let channelData = audioPCMBuffer.floatChannelData else {
            return nil
        }
        
        do {
            try audioFile.read(into: audioPCMBuffer)
        } catch {
            return nil
        }
        
        let channelCount = Int(audioPCMBuffer.format.channelCount)
        let renderSamples = 0..<Int(audioFile.length)
        let samplePerPoint = renderSamples.count / Int(width)
        
        var volumeLevels = [Float]()
        
        for point in 0..<Int(width) {
            for channel in 0..<channelCount {
                let pointer = channelData[channel].advanced(by: renderSamples.lowerBound + Int(point * samplePerPoint))
                let stride = vDSP_Stride(audioPCMBuffer.stride)
                let length = vDSP_Length(samplePerPoint)
                
                var minValue: Float = 0
                var maxValue: Float = 0
                
                vDSP_minv(pointer, stride, &minValue, length)
                vDSP_maxv(pointer, stride, &maxValue, length)
                
                let rootMeanSquare = (sqrt(minValue * minValue) + sqrt(maxValue * maxValue)) / 2
                let averagePower = 30 * log10(rootMeanSquare)
                let volumeLevel = self.scalePower(power: averagePower)
                volumeLevels.append(volumeLevel)
            }
        }
        
        return volumeLevels
    }
    
    /// 재생중인 audioFile의 현재 PlayerTime의 FramePosition을 반환
    private func getCurrentFramePosition(nodeTime: AVAudioTime, audioFile: AVAudioFile, moveOffset: AVAudioFramePosition) -> AVAudioFramePosition? {
        
        guard let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else  {
            return nil
        }
        
        let audioLengthSamples = audioFile.length
        
        var currentFrame = playerTime.sampleTime + seekFrame
        currentFrame = validateFrameEdge(with: currentFrame,
                                         limit: audioLengthSamples)
        
        return validateFrameEdge(with: currentFrame + moveOffset,
                                 limit: audioLengthSamples)
    }
}
