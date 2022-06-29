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
    
    init(url : URL){
        player = {
            let player = AVPlayer()
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            print("player ready on")
            return player
        }()
    }
    
    func playAudio(){
        player.play()
    }
    
    func stopAudio(){
        player.pause()
    }
}
