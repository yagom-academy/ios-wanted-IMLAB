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
    
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    var pitchControl = AVAudioUnitTimePitch()
    
    weak var delegate : PlayVoiceDelegate!
    var isPlay = false
    
    
    
    init(){
        let fileURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myRecoding.m4a").path)
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {return}
        
        playerNode.volume = 0.5
        
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        
        audioEngine.connect(playerNode, to: pitchControl, format: nil)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
//        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        self.audioEngine.prepare()
        do{
            try audioEngine.start()
            print(audioEngine.mainMixerNode.outputVolume)
        }catch{
            print("AUDIO ENGINE START ERROR")
        }
        setScheduleFile(audioFile: audioFile)
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
        playerNode.pause()
        playerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack) { _ in
            self.delegate.playEndTime()
            self.setScheduleFile(audioFile: audioFile)
        }
    }
    
    func forwardFiveSecond(){

    }
        
    func seek(time : Double){
        
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
}
