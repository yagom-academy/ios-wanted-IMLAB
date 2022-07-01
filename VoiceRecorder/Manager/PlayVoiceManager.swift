//
//  PlayVoiceManager.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/29.
//

protocol PlayVoiceDelegate{
    func playEndTime()
}

import Foundation
import AVFoundation
import NotificationCenter

class PlayVoiceManager{
    var player : AVPlayer!
    var isPlay = false
    var delegate : PlayVoiceDelegate?
    
    init(url : URL){
        player = {
            let player = AVPlayer()
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.volume = 0.5
            return player
        }()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    
    func playAudio(){
        isPlay = true
        player.play()
    }
    
    func stopAudio(){
        isPlay = false
        player.pause()
    }
    
    func isPlaying()->Bool{
        return isPlay
    }
    
    func setVolume(volume : Float){
        player.volume = volume
    }
    
    func getVolume()->Float{
        return player.volume
    }
    
    @objc func playerDidFinishPlaying(){
        delegate?.playEndTime()
        self.player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
    }
    
    func forwardFiveSecond(){
        //seek는 x초로 이동. 현재 시간 기준 아님
        var currentTime = player.currentTime()
        var interval = CMTime(seconds: 5, preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.seek(to: currentTime+interval)
    }
    
    func backwardFiveSecond(){
        var currentTime = player.currentTime()
        var interval = CMTime(seconds: 5, preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.seek(to: currentTime-interval)
    }
}
