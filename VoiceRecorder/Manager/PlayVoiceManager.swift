//
//  PlayVoiceManager.swift
//  VoiceRecorder
//
//  Created by JunHwan Kim on 2022/06/29.
//

import Foundation
import AVFoundation

class PlayVoiceManager{
    var player : AVPlayer!
    var isPlay = false
    
    init(url : URL){
        player = {
            let player = AVPlayer()
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.volume = 0.5
            print("player ready on")
            return player
        }()
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
    
    func setVolume(){
        print(player.volume)
    }
}
