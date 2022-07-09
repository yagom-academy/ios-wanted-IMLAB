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
    private var sendWaves: [Int] = Array(repeating: 1, count: 100)

    private var timer: Timer?
    var interval = 0
    var currentTime = 0

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer

        NotificationCenter.default.addObserver(self, selector: #selector(getWaves(_:)), name: Notification.Name("GetTotalWaves"), object: nil)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("SendWaveform"), object: self.sendWaves)
        }
    }

    @objc func getWaves(_ notification: Notification) {
        guard let waves = notification.object as? [Int] else { return }
        self.waves = waves
    }

    func removeObserver() {
        timer?.invalidate()

        NotificationCenter.default.removeObserver(self, name: Notification.Name("GetTotalWaves"), object: nil)
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
        
        removedWaves.append(sendWaves.removeFirst())
        sendWaves.append(waves[interval])

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
        
        let count = removedWaves.count

        if count < 50 {
            interval -= count
            sendWaves = removedWaves + Array(sendWaves[0 ..< 100 - count])
            removedWaves.removeAll()
            sendToFrequencyView()
        } else {
            interval -= 50
            if interval < 0 {
                interval = 0
            }
            sendWaves = Array(removedWaves[count - 50 ..< count]) + Array(sendWaves[0 ... 49])
            removedWaves = Array(removedWaves[0 ..< count - 50])
            sendToFrequencyView()
        }
    }

    func goForward() {
        audioPlayer.skip(+)
        
        if interval + 50 > waves.count {
            removedWaves += Array(sendWaves[0 ..< (waves.count - interval)])
            interval = waves.count - 1
            var startIndex = 0
            if waves.count >= 100 {
                startIndex = waves.count - 100
            }
            sendWaves = Array(waves[startIndex ..< waves.count])

            sendToFrequencyView()
        } else {
            interval += 50
            removedWaves += Array(sendWaves[0 ..< 50])
            sendWaves = Array(sendWaves[50 ..< 100]) + Array(waves[interval - 50 ..< interval])

            sendToFrequencyView()
        }
    }
}
