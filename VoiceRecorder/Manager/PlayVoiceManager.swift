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
    //재생할 오디오 파일
    var audioFile : AVAudioFile?
    var format : AVAudioFormat?
    //player 노드
    
    
    //오디오 엔진
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    var pitchControl = AVAudioUnitTimePitch()
    weak var delegate : PlayVoiceDelegate!
    var isPlay = false
    
    
    
    init(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myRecoding.m4a")
        guard let file = try? AVAudioFile(forReading: fileURL) else {return}
        audioFile = file
        format = file.processingFormat
        playerNode.volume = 0.5
        
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        
        audioEngine.connect(playerNode, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: format)
        
        self.audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            print("AUDIO ENGINE START ERROR")
        }
        setScheduleFile(audioFile: file)
    }
    
    func setAudio(){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("myRecoding.m4a")
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {return}
        let format = audioFile.processingFormat
        self.audioFile = audioFile
        setEngine(format: format)
    }
    
    func setEngine(format : AVAudioFormat){
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        
        audioEngine.connect(playerNode, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: format)
        
        self.audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            print("AUDIO ENGINE START ERROR")
        }
    }
    
    func playAudio(){
        isPlay = true
        playerNode.play()
    }
    
    func stopAudio(){
        isPlay = false
        playerNode.pause()
        }
    
    func setScheduleFile(audioFile : AVAudioFile){
        playerNode.scheduleFile(audioFile, at: AVAudioTime(hostTime: 0), completionCallbackType: .dataPlayedBack) { _ in
            self.delegate.playEndTime()
        }
    }
    
    func forwardFiveSecond(){
        //현재까지 재생된 오디오의 프레임 위치
        playerNode.stop()
        guard let audioFile = audioFile else {
            return
        }
        playerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack)
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
    
    deinit{
        print("Close PlayVoice Manager")
    }
}
