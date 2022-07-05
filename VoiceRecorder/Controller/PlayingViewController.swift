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
    var pitchTimer: Timer!
    var playTimer: Timer!
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
        audioPlayerHandler.selectPlayFile(self.fileNameLabel.text)
        audioPlayerHandler.prepareToPlay()
        audioPlayerHandler.setEngine()
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
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            setButton(enable: true)
            audioPlayerHandler.audioPlayerNode.play()
            setTimer(validate: true)
            totalPlayTimeLabel.text = audioPlayerHandler.updateTimer(audioPlayerHandler.audioPlayer.duration)
        } else {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            setButton(enable: false)
            audioPlayerHandler.audioPlayerNode.pause()
        }
        inPlayMode.toggle()
    }

    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        let player = audioPlayerHandler.audioPlayer
        player.currentTime = player.currentTime + 5.0
        player.play()
    }
    
    func setTimer(validate: Bool) {
        if validate {
            pitchTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(confirmSoundPitchDidChange), userInfo: nil, repeats: true)
            playTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(audioplayerNodeDidFinishPlaying), userInfo: nil, repeats: true)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        } else {
            pitchTimer.invalidate()
            playTimer.invalidate()
            progressTimer.invalidate()
        }
        
    }
    
    @objc func confirmSoundPitchDidChange() {
        switch soundPitchControl.selectedSegmentIndex {
        case 0:
            audioPlayerHandler.changePitch(to: 0)
        case 1:
            audioPlayerHandler.changePitch(to: 800)
        case 2:
            audioPlayerHandler.changePitch(to: -900)
        default:
            break
        }
    }
    
    @objc func audioplayerNodeDidFinishPlaying() {
        if audioPlayerHandler.audioPlayerNode.currentTime > audioPlayerHandler.audioFile.duration {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            audioPlayerHandler.audioPlayerNode.stop()
            audioPlayerHandler.stopEffect()
            audioPlayerHandler.setEngine()
            setButton(enable: false)
            setTimer(validate: false)
            inPlayMode.toggle()
        }
    }
    
    @objc func updateProgress() {
        let currentTime = audioPlayerHandler.audioPlayerNode.currentTime
        let duration = audioPlayerHandler.audioFile.duration
        currentPlayTimeLabel.text = audioPlayerHandler.updateTimer(currentTime)
        let time = Float(currentTime / duration)
        playProgressBar.setProgress(time, animated: true)
    }
}
