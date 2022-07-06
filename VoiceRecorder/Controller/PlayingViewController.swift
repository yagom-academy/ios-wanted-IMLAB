//
//  PlayingViewController.swift
//  VoiceRecorder
//
//  Created by CHUBBY on 2022/07/02.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayingViewController: UIViewController {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    var selectedFileInfo: RecordModel?
    var progressTimer: Timer?
    var inPlayMode: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPlayTimeLabel.text = "00:00"
        guard let fileInfo = selectedFileInfo else { return }
        self.fileNameLabel.text = fileInfo.recordFileName
        self.totalPlayTimeLabel.text = fileInfo.recordTime
        playProgressBar.progress = 0.0
        audioPlayerHandler.selectPlayFile(self.fileNameLabel.text)
        audioPlayerHandler.prepareToPlay()
        audioPlayerHandler.setEngine()
        configureVolumeSlider()
    }
    
    let audioPlayerHandler = AudioPlayerHandler(handler: LocalFileHandler(), updateTimeInterval: UpdateTimeInterval())
    
    func configureVolumeSlider() {
        let volumeView = MPVolumeView()
        volumeView.showsRouteButton = false
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeView)
        NSLayoutConstraint.activate([
            volumeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            volumeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            volumeView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
    }
    
    func setButton(enable: Bool) {
        goBackwardButton.isEnabled = enable
        goForwardButton.isEnabled = enable
    }
    
    @IBAction func changePitch(_ sender: UISegmentedControl) {
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
    
    @IBAction func goBackwardButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        if inPlayMode {
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
            setButton(enable: true)
            audioPlayerHandler.audioPlayerNode.play()
            totalPlayTimeLabel.text = audioPlayerHandler.updateTimer(audioPlayerHandler.audioPlayer.duration)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        } else {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            setButton(enable: false)
            audioPlayerHandler.audioPlayerNode.pause()
        }
        inPlayMode.toggle()
    }
    
    
    @objc func updateProgress() {
        let currentTime = audioPlayerHandler.audioPlayerNode.currentTime
        let duration = audioPlayerHandler.audioFile.duration
        currentPlayTimeLabel.text = audioPlayerHandler.updateTimer(currentTime)
        let time = Float(currentTime / duration)
        playProgressBar.setProgress(time, animated: true)
        
        if audioPlayerHandler.audioPlayerNode.currentTime > audioPlayerHandler.audioFile.duration {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            audioPlayerHandler.audioPlayerNode.stop()
            audioPlayerHandler.setEngine()
            setButton(enable: false)
            inPlayMode.toggle()
        }
    }
}
