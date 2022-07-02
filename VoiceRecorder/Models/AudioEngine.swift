//
//  AudioEngine.swift
//  VoiceRecorder
//
//  Created by yc on 2022/07/02.
//

import AVKit

class AudioEngine {
    private let engine = AVAudioEngine()
    private let audioPlayer = AVAudioPlayerNode()
    private let speedControl = AVAudioUnitVarispeed()
    private let pitchControl = AVAudioUnitTimePitch()
    
    var url: URL?
    var audioFile: AVAudioFile?
    
    func setupEngine() throws {
        guard let url = url else { return }
        let file = try AVAudioFile(forReading: url)
        audioFile = file
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        audioPlayer.scheduleFile(file, at: nil)
        try engine.start()
    }
    func play() {
        audioPlayer.play()
    }
    func pause() {
        engine.stop()
        audioPlayer.pause()
    }
    func setPitch(_ value: Float) {
        pitchControl.pitch = value
    }
    func getCurrentTime() -> Double {
        guard let nodeTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: nodeTime) else { return 0.0 }
        
        return Double(playerTime.sampleTime) / playerTime.sampleRate
    }
    func seek(to: Double) {
    }
}
