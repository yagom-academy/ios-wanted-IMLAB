//
//  RecordViewModel.swift
//  VoiceRecorder
//
//  Created by 이경민 on 2022/07/02.
//

import Foundation
import AVFAudio
import Combine
import QuartzCore

protocol RecordDrawable: AnyObject{
    func updateValue(_ value:CGFloat)
    func clearAll()
}

class RecordViewModel {
    let storage = FirebaseStorageManager.shared
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    var recordFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 1, interleaved: true)
    let recordFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("input.m4a"))
    
    private var displayLink: CADisplayLink?
    
    @Published var progressValue: Float = 0
    @Published var isPlaying: Bool = false
    @Published var isRecording: Bool = false
    
    weak var delegate: RecordDrawable?
    
    init() {
        prepareRecorder()
        setupDisplayLink()
    }
    
    func prepareRecorder() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            recorder = try AVAudioRecorder(url: recordFileURL, settings: recordFormat!.settings)
        } catch {
            print("Could not Prepare Recorder \(error)")
        }
    }
    
    func startRec() {
        recorder.record()
        recorder.isMeteringEnabled = true
        isRecording = recorder.isRecording
        delegate?.clearAll()

        DispatchQueue.global(qos: .background).async {
            while self.recorder.isRecording {
                self.recorder.updateMeters()
    //                print(self.recorder.averagePower(forChannel: 0))
                self.delegate?.updateValue(self.nomalizeSoundLevel(level: self.recorder.averagePower(forChannel: 0)))
            }
        }

    }
    
    func stopRec() {
        recorder.stop()
        isRecording = recorder.isRecording
        storage.uploadData(url: recordFileURL, fileName: Date().toString("yyyy_MM_dd_HH:mm:ss"))
    }
    
    func playAudio() {
        do {
            player = try AVAudioPlayer(data: getDataFrom())
            player.volume = 0.5
            player.play()
            displayLink?.isPaused = false
            isPlaying = player.isPlaying
        } catch {
            print("Fail to play audio")
        }
    }
    
    func stopAudio() {
        player.pause()
        isPlaying = false
    }
    
    func getDataFrom() -> Data {
        guard let data = try? Data(contentsOf: recordFileURL) else {
            print("Data is Not Unwrapping")
            return Data()
        }
        print(data.description)
        return data
    }
    
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.isPaused = true
    }

    func seek(front:Bool){
        displayLink?.isPaused = true

        player.pause()
        
        var currentTime = player.currentTime
        currentTime += front ? 5:-5
        
        updateDisplay()
        
        if currentTime > player.duration {
            stopAudio()
            player.currentTime = 0
        } else {
            player.currentTime = currentTime
            player.play()
            isPlaying = player.isPlaying
        }
        
        displayLink?.isPaused = false
    }
    
    @objc private func updateDisplay() {
        let currentPosition = player.currentTime
        let totalPosition = player.duration
        isPlaying = player.isPlaying
        
        progressValue = Float(currentPosition) / Float(totalPosition)
        
    }
    
    private func nomalizeSoundLevel(level:Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
//        print(level)
//        print(CGFloat(level * (80 / 25)))
        return CGFloat(level * (80 / 25))
    }
}

