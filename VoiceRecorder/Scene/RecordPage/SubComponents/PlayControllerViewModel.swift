//
//  PlayControllerViewModel.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/07/07.
//

import Foundation

class PlayControllerViewModel {
    private var audioPlayer: PlayerService
    
    private var waves: [Int] = []
    private var removedWaves: [Int] = []
    private var sendWaves: [Int] = Array(repeating: 0, count: 100)

    private var timer: Timer?
    var interval = 0
    var currentTime = 0

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer
        
        NotificationCenter.default.addObserver(self, selector: #selector(getWaves(_:)), name: Notification.Name("GetTotlaWaves"), object: nil)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("SendWaveform"), object: self.sendWaves)
        }
    }
    
    @objc func getWaves(_ notification: Notification) {
        guard let waves = notification.object as? [Int] else { return }
        self.waves = waves
    }
    
    func playPauseAudio() -> Bool {
        if audioPlayer.isPlaying {
            audioPlayer.pausePlayer()
            timer?.invalidate()
            return false
        } else {
            audioPlayer.startPlayer()

            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimeFires), userInfo: nil, repeats: true)

            return true
        }
    }

    @objc private func onTimeFires() {
        if interval + 1 == waves.count {
            timer?.invalidate()
            interval = 0
            sendWaves = Array(repeating: 1, count: 100)
        }
        
        if interval >= sendWaves.count {
            removedWaves.append(sendWaves.removeFirst())
            sendWaves.append(waves[interval])
        } else {
            sendWaves[interval] = waves[interval]
        }

        sendToFrequencyView()

        interval += 1
    }

    private func sendToFrequencyView() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("SendWaveform"), object: self.sendWaves)
        }
    }

    func goBackward() {
        audioPlayer.skip(-)
    }

    func goForward() {
        audioPlayer.skip(+)
    }
}
