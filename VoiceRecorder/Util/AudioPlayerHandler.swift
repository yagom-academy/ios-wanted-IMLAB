//
//  AudioPlayerHandler.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/06/30.
//

import Foundation
import AVFoundation

class AudioPlayerHandler {
    
    var audioPlayer = AVAudioPlayer()
    var localFileHandler: LocalFileProtocol
    var updateTimeInterval: UpdateTimer
    var recordFileURL: URL!
    var buffer: AVAudioPCMBuffer?
    var audioFile: AVAudioFile?
    
    init(handler: LocalFileProtocol, updateTimeInterval: UpdateTimer) {
        self.localFileHandler = handler
        self.updateTimeInterval = updateTimeInterval
    }
    
    func selectPlayFile(_ fileName: String?) {
        if fileName == nil {
            let latestRecordFileName = localFileHandler.getLatestFileName()
            let latestRecordFileURL = localFileHandler.localFileURL.appendingPathComponent(latestRecordFileName)
            self.recordFileURL = latestRecordFileURL
        } else {
            guard let playFileName = fileName else { return }
            let selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("voiceRecords_\(playFileName)")
            self.recordFileURL = selectedFileURL
        }
    }
    
    func prepareToPlay() {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: recordFileURL)
            self.audioPlayer = audioPlayer
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.volume = 5.0
        } catch let error {
            print("Error : setUpPlayer - \(error)")
        }
    }
    
    func updateTimer(_ time: TimeInterval) -> String {
        return updateTimeInterval.updateTimer(time)
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false, fileName: String) {
        
        do {
            let selectedFileURL = localFileHandler.localFileURL.appendingPathComponent("voiceRecords_\(fileName)")
            audioFile = try AVAudioFile(forReading: selectedFileURL)
            buffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(audioFile!.length))
            try audioFile!.read(into: buffer!)
        } catch {
            print(error.localizedDescription)
        }
        // initialize audio engine components
        let audioEngine = AVAudioEngine()
        
        // node for playing audio
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            audioEngine.connect(audioPlayerNode, to: echoNode, format: buffer!.format)
            audioEngine.connect(audioPlayerNode, to: reverbNode, format: buffer!.format)
            audioEngine.connect(echoNode, to: audioEngine.mainMixerNode, format: buffer!.format)
            audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: buffer!.format)
        } else if echo == true {
            audioEngine.connect(audioPlayerNode, to: echoNode, format: buffer!.format)
            audioEngine.connect(echoNode, to: audioEngine.mainMixerNode, format: buffer!.format)
        } else if reverb == true {
            audioEngine.connect(audioPlayerNode, to: reverbNode, format: buffer!.format)
            audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: buffer!.format)
        } else {
            audioEngine.connect(audioPlayerNode, to: changeRatePitchNode, format: audioFile!.processingFormat)
            audioEngine.connect(changeRatePitchNode, to: audioEngine.outputNode, format: audioFile!.processingFormat)
            audioEngine.connect(changeRatePitchNode, to: audioEngine.mainMixerNode, format: buffer!.format)
        }
        
       // audioPlayerNode.volume = volumeSlider.value / 100
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile!, at: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
}
