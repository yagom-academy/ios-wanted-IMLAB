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
    
    var isPlay = false
    
    init(){
        let fileURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myRecoding.m4a").path)
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {return}
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        playerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack){_ in
            //앱 재생 완료 후 구현
        }
    }
    
    func playAudio(){
            isPlay = true
        do{
            try audioEngine.start()
            playerNode.play()
        }catch{
            print("Play Audio Error")
        }
    }
    
//    var player : AVPlayer!
//    var isPlay = false
//    weak var delegate : PlayVoiceDelegate?
//
//    init(url : URL){
//        player = {
//            let player = AVPlayer()
//            let playerItem = AVPlayerItem(url: url)
//            player.replaceCurrentItem(with: playerItem)
//            player.volume = 0.5
//            return player
//        }()
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//    }
//
//
//
//
//    func stopAudio(){
//        isPlay = false
//        player.pause()
//    }
//
//    func isPlaying()->Bool{
//        return isPlay
//    }
//
//    func setVolume(volume : Float){
//        player.volume = volume
//    }
//
//    func getVolume()->Float{
//        return player.volume
//    }
//
//    @objc func playerDidFinishPlaying(){
//        delegate?.playEndTime()
//        self.player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
//    }
//
//    func forwardFiveSecond(){
//        //seek는 x초로 이동. 현재 시간 기준 아님
//        var currentTime = player.currentTime()
//        var interval = CMTime(seconds: 5, preferredTimescale: Int32(NSEC_PER_SEC))
//        self.player.seek(to: currentTime+interval)
//    }
//
//    func backwardFiveSecond(){
//        var currentTime = player.currentTime()
//        var interval = CMTime(seconds: 5, preferredTimescale: Int32(NSEC_PER_SEC))
//        self.player.seek(to: currentTime-interval)
//    }
}
