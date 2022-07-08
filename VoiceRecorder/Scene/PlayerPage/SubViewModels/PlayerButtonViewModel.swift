//
//  PlayerButtonViewModel.swift
//  VoiceRecorder
//
//  Created by 장재훈 on 2022/07/04.
//

import AVFAudio
import ClockKit
import Foundation

class PlayerButtonViewModel {
    private var audioPlayer: PlayerService

    private var waves: [Int] = []
    private var removedWaves: [Int] = []
    private var sendWaves: [Int] = Array(repeating: 1, count: 100)

    private var timer: Timer?
    var interval = 0
    var currentTime = 0

    init(_ audioPlayer: PlayerService) {
        self.audioPlayer = audioPlayer

        NotificationCenter.default.addObserver(self, selector: #selector(getWaves(_:)), name: Notification.Name("GetWaves"), object: nil)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("SendWaveform"), object: self.sendWaves)
        }
    }

    @objc func getWaves(_ notification: Notification) {
        guard let waves = notification.object as? [Int] else { return }
        self.waves = waves
    }

    func resetViewModel() {
        timer?.invalidate()

        NotificationCenter.default.removeObserver(self, name: Notification.Name("GetWaves"), object: nil)
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

    func setAudioFile(_ audioFile: AVAudioFile) {
        audioPlayer.setAudioFile(audioFile)
    }

    func duration() -> String {
        return audioPlayer.duration()
    }

    func secondsToString(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "00:00"
        }

        let duration = Int(seconds)
        var result = ""

        let min = duration / 60
        let sec = duration % 60

        result += min < 10 ? "0\(min):" : "\(min)"
        result += sec < 10 ? "0\(sec)" : "\(sec)"

        return result
    }

    func getCurrentTime() -> Int {
        return currentTime
    }

    func setCurrentTime(_ value: Int) {
        currentTime = value
    }

    func incrementCurrentTime(_ value: Int) {
        currentTime += value
    }
}
