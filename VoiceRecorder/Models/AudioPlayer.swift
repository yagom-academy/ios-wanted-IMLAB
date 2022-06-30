//
//  AudioPlayer.swift
//  VoiceRecorder
//
//  Created by yc on 2022/06/30.
//

import AVFAudio
import UIKit

class AudioPlayer: NSObject {
    
    private var player: AVAudioPlayer?
    var data: Data?
    var url: URL?
    
    var didFinish: (() -> ())?
    
    var currentTime: TimeInterval {
        get {
            player?.currentTime ?? 0.0
        } set {
            player?.currentTime = newValue
        }
    }
    var duration: TimeInterval { player?.duration ?? 0.0 }
    var isPlaying: Bool { player?.isPlaying ?? false }
    
    func setupPlayer() {
        guard let url = url else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume = 1.0
            player?.prepareToPlay()
        } catch {
            print("ERROR")
        }
    }
    
    func play() {
        guard let player = player else { return }
        player.play()
    }
    func pause() {
        guard let player = player else { return }
        player.pause()
    }
    func stop() {
        guard let player = player else { return }
        player.stop()
    }
    func seek(_ to: Double) {
        guard let player = player else { return }
        player.currentTime += to
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinish?()
    }
}
