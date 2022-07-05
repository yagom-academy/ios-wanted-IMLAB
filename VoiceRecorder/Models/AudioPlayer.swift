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
    
    var url: URL?
    var data: Data? {
        if let url = url {
            do {
                return try Data(contentsOf: url)
            } catch {
                return nil
            }
        }
        return nil
    }
    
    var didFinish: (() -> Void)?
    
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
        guard let data = data else { return }
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            player?.volume = 1.0
            player?.prepareToPlay()
        } catch {
            print("ERROR 🎒🎒 \(error.localizedDescription)")
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
