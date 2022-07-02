//
//  PlayingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/07/02.
//

import UIKit
import AVFoundation

class PlayingViewController: UIViewController {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    var selectedFileInfo: RecordModel?
    var progressTimer: Timer!
    var inPlayMode: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPlayTimeLabel.text = "00:00"
        guard let fileInfo = selectedFileInfo else { return }
        self.fileNameLabel.text = fileInfo.recordFileName
        self.totalPlayTimeLabel.text = fileInfo.recordTime
        volumeSlider.maximumValue = 10.0
        volumeSlider.value = 5.0
        playProgressBar.progress = 0.0
    }
    
    let audioPlayerHandler = AudioPlayerHandler(handler: LocalFileHandler(), updateTimeInterval: UpdateTimeInterval())
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        let player = audioPlayerHandler.audioPlayer
        player.currentTime = player.currentTime - 5.0
        player.play()
    }
    
    func setButton(enable: Bool) {
        goBackwardButton.isEnabled = enable
        goForwardButton.isEnabled = enable
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if inPlayMode {
            audioPlayerHandler.audioPlayer.volume = volumeSlider.value
            setButton(enable: true)
            audioPlayerHandler.audioPlayer.delegate = self
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            audioPlayerHandler.startPlay(isSelectedFile: true, fileName: self.fileNameLabel.text!)
            totalPlayTimeLabel.text = audioPlayerHandler.updateTimer(audioPlayerHandler.audioPlayer.duration)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                 target: self,
                                                 selector: #selector(updatePlayTime),
                                                 userInfo: nil,
                                                 repeats: true)
        } else {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            setButton(enable: false)
            audioPlayerHandler.audioPlayer.pause()
        }
        inPlayMode.toggle()
    }
    
    @objc func updatePlayTime() {
        let player = audioPlayerHandler.audioPlayer
        currentPlayTimeLabel.text = audioPlayerHandler.updateTimer(player.currentTime)
        let time = Float(player.currentTime / (player.duration - 1.0))
        playProgressBar.setProgress(time, animated: true)
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        let player = audioPlayerHandler.audioPlayer
        player.currentTime = player.currentTime + 5.0
        player.play()
    }
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        audioPlayerHandler.audioPlayer.volume = volumeSlider.value
    }
}

extension PlayingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
        playProgressBar.progress = 0
        progressTimer.invalidate()
    }
}
