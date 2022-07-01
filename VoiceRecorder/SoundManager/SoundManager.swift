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
    
    private let playerNode = AVAudioPlayerNode()
    private let engine = AVAudioEngine()
    private let pitchControl = AVAudioUnitTimePitch()
    
    override init() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func initializedPlayer(url: URL) {
        
        do {
            
            
            let file = try AVAudioFile(forReading: url)
            let fileFormat = file.processingFormat
            let customFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 2, interleaved: false)
            let tapNode = AVAudioNode()
            tapNode.installTap(onBus: <#T##AVAudioNodeBus#>, bufferSize: <#T##AVAudioFrameCount#>, format: <#T##AVAudioFormat?#>, block: <#T##AVAudioNodeTapBlock##AVAudioNodeTapBlock##(AVAudioPCMBuffer, AVAudioTime) -> Void#>)
            print(file.length)
            print(fileFormat.sampleRate)
            print(Double(file.length)/fileFormat.sampleRate)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: customFormat!, frameCapacity: AVAudioFrameCount(file.length)) else { return }
            try file.read(into: buffer)
            
            print("시작전",engine.attachedNodes)
            engine.attach(playerNode)
            engine.attach(pitchControl)
            
            engine.connect(playerNode, to: pitchControl, format: nil)
            engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
            
            playerNode.scheduleBuffer(buffer) { [self] in
                delegate?.observeAudioPlayerDidFinishPlaying(playerNode)
            }
            
        
            engine.prepare()
            print("초기화 후",engine.attachedNodes)
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
    }
    
    func play() {
        try! engine.start()
        playerNode.play()
        
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func changePitchValue(value: Float) {
        self.pitchControl.pitch = value
    }
    func changeVolume(value: Float) {
        self.playerNode.volume = value
    }
    
}
