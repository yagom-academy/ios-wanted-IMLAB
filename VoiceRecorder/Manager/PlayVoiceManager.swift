//
//  PlayVoiceManager.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/29.
//

protocol PlayVoiceDelegate : AnyObject{
    func playEndTime()
}

import Foundation
import AVFoundation
import NotificationCenter

class PlayVoiceManager{
    //재생할 오디오 파일 정보
    var audioFile : AVAudioFile?
    var format : AVAudioFormat?
    var audioFileSampleRate : Double = 0
    var audioFileLengthSecond : Double = 0
    var audioLengthSamples : AVAudioFramePosition = 0
    var currentPosition : AVAudioFramePosition = 0
    var seekFrame : AVAudioFramePosition = 0
    var currentFrame : AVAudioFramePosition{
        guard let lastRenderTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime)
        else{
            return 0
        }
        return playerTime.sampleTime
    }
    //오디오 엔진
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    var pitchControl = AVAudioUnitTimePitch()
    weak var delegate : PlayVoiceDelegate!
    var isPlay = false
    
    var displayLink : CADisplayLink?
    
    init(){
        setAudio()
        setDisplayLink()
    }
    
    func setAudioFile(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("myRecoding.m4a")
        print(fileURL)
        guard let file = try? AVAudioFile(forReading: fileURL) else {return}
        self.format = file.processingFormat
        self.audioFile = file
        self.audioFileSampleRate = file.processingFormat.sampleRate
        self.audioLengthSamples = file.length
        audioFileLengthSecond = Double(audioLengthSamples) / audioFileSampleRate
    }
    
    func setAudio(){
        setAudioFile()
        setEngine(format: self.format ?? nil)
    }
    
    func setEngine(format : AVAudioFormat?){
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        
        audioEngine.connect(playerNode, to: pitchControl, format: format)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: format)
        //audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: format)
        
        self.audioEngine.prepare()
        do{
            try audioEngine.start()
            setScheduleFile()
        }catch{
            print("AUDIO ENGINE START ERROR")
        }
    }
    
    func setScheduleFile(){
        guard let file = audioFile else {return}
        playerNode.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { _ in
            self.delegate.playEndTime()
        }
        print("END")
    }
    
    func playAudio(){
        isPlay = true
        displayLink?.isPaused = false
        playerNode.play()
    }
    
    func stopAudio(){
        isPlay = false
        displayLink?.isPaused = true
        playerNode.pause()
        }
    
    func setNewScheduleFile(){
        playerNode.stop()
        setAudioFile()
        setScheduleFile()
        print("NEW SCHEDULEFILE")
    }
    
    func forwardFiveSecond(){
        print(currentFrame)
        print(audioLengthSamples)
    }
        
    func seek(to : Double){
        
    }
    
    func setVolume(volume : Float){
        playerNode.volume = volume
    }
    
    func getVolume()->Float{
        return playerNode.volume
    }
    
    func setPitch(pitch : SoundPitch){
        switch pitch {
        case .normal:
            pitchControl.pitch = 0
        case .young:
            pitchControl.pitch = 500
        case .old:
            pitchControl.pitch = -500
        }
    }
    
    func setDisplayLink(){
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    @objc func updateDisplay(){
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        if currentPosition >= audioLengthSamples{
            playerNode.stop()
            seekFrame = 0
            currentPosition = 0
            isPlay = false
            displayLink?.isPaused = true
            delegate.playEndTime()
            setScheduleFile()
        }
    }
    
    deinit{
        print("Close PlayVoice Manager")
    }
}

