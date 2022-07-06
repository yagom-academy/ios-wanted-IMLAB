//
//  PlayVoiceManager.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/29.
//

protocol PlayVoiceDelegate : AnyObject{
    func playEndTime()
    func displayWaveForm(to currentPosition : AVAudioFramePosition, in audioLengthSamples : AVAudioFramePosition)
}

import Foundation
import AVFoundation
import NotificationCenter

class PlayVoiceManager{
    //재생할 오디오 파일 정보
    private var audioFile : AVAudioFile?
    private var format : AVAudioFormat?
    private var audioFileSampleRate : Double = 0
    private var audioFileLengthSecond : Double = 0
    private var audioLengthSamples : AVAudioFramePosition = 0
    private var currentPosition : AVAudioFramePosition = 0
    private var seekFrame : AVAudioFramePosition = 0
    private var currentFrame : AVAudioFramePosition{
        guard let lastRenderTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime)
        else{
            return 0
        }
        return playerTime.sampleTime
    }
    //오디오 엔진
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var pitchControl = AVAudioUnitTimePitch()
    weak var delegate : PlayVoiceDelegate!
    var isPlay = false
    
    private var displayLink : CADisplayLink?
    
    init(){
        print("CREATE PLAYVOICEMANAGER")
        setAudio()
        setDisplayLink()
    }
    
    func setAudioFile(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("myRecoding.m4a")
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
    
    private func setEngine(format : AVAudioFormat?){
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
        playerNode.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack)
    }
    
    func playOrPauseAudio(){
        isPlay.toggle()
        if isPlay{
            playerNode.play()
            displayLink?.isPaused = false
        }else{
            playerNode.pause()
            displayLink?.isPaused = true
        }
    }
    
    func closeAudio(){
        isPlay = false
        displayLink?.isPaused = true
        displayLink = nil
        playerNode.stop()
        audioEngine.stop()
    }
    
    func setNewScheduleFile(){
        playerNode.stop()
        isPlay = false
        setAudioFile()
        setScheduleFile()
    }
    
    func forwardOrBackWard(forward : Bool){
        var seekTime : Double
        if forward{
            seekTime = 5.0
        }else{
            seekTime = -5.0
        }
        seek(time: seekTime)
        delegate.displayWaveForm(to: currentPosition, in: audioLengthSamples)
    }
        
    private func seek(time : Double){
        guard let audioFile = audioFile else {
            return
        }
        let wasPlaying = playerNode.isPlaying
        let interval = AVAudioFramePosition(time * audioFileSampleRate)
        seekFrame = currentPosition + interval
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        playerNode.stop()
        
        if currentPosition < audioLengthSamples{
        
        let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
        playerNode.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: frameCount, at: nil) {
            print("COMPLETE")
        }
        if wasPlaying{
            playerNode.play()
        }
        }else{
            delegate.displayWaveForm(to: 0, in: audioLengthSamples)
            playerNode.stop()
            seekFrame = 0
            currentPosition = 0
            isPlay = false
            displayLink?.isPaused = true
            delegate.playEndTime()
            delegate.displayWaveForm(to: 0, in: audioLengthSamples)
            setScheduleFile()
        }
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
    
    private func setDisplayLink(){
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    @objc private func updateDisplay(){
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        if currentPosition >= audioLengthSamples{
            delegate.displayWaveForm(to: audioLengthSamples, in: audioLengthSamples)
            playerNode.stop()
            seekFrame = 0
            currentPosition = 0
            isPlay = false
            displayLink?.isPaused = true
            delegate.playEndTime()
            setScheduleFile()
        } else {
            delegate.displayWaveForm(to: currentPosition, in: audioLengthSamples)
        }
        
    }
    
    deinit{
        print("Close PlayVoice Manager")
    }
}

