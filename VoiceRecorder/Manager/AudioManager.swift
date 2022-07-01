//
//  AudioManager.swift
//  VoiceRecorder
//
//  Created by J_Min on 2022/07/01.
//

import Foundation
import AVFoundation

class AudioManager {
    var filePath: URL
    let audioEngine = AVAudioEngine()
    let audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    lazy var audioEQFilterParameters = audioEQ.bands[0]
    var inputNode: AVAudioInputNode!
    var mixerNode = AVAudioMixerNode()
    var cutOffFrequency: Float = 0
    
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
    private func createNode() {
        inputNode = audioEngine.inputNode
        mixerNode.outputVolume = 1
    }
    
    // eq
    private func createEqFilter() {
        audioEQFilterParameters.filterType = .lowPass
        audioEQFilterParameters.frequency = cutOffFrequency
    }
    
    private func attachNodes() {
        audioEngine.attach(mixerNode)
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
        createNode()
        createEqFilter()
        attachNodes()
        connectNodes()
        
        let format = audioEQ.outputFormat(forBus: 0)
        guard let audioFile = try? createAudioFile(filePath: filePath) else {
            fatalError()
        }
        
        audioEQ.removeTap(onBus: 0)
        audioEQ.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            do {
                try audioFile.write(from: buffer)
            } catch {
                fatalError()
            }
        }
    }
}
