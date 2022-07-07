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
    
    @IBOutlet weak var volumeSliderView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    var selectedFileInfo: RecordModel?
    private var progressTimer: Timer?
    private var inPlayMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPlayTimeLabel.text = "00:00"
        guard let fileInfo = selectedFileInfo else { return }
        self.fileNameLabel.text = fileInfo.recordFileName
        self.totalPlayTimeLabel.text = fileInfo.recordTime
        playProgressBar.progress = 0.0
        audioPlayerHandler.selectPlayFile(self.fileNameLabel.text)
        configureVolumeSlider()
    }
    
    let audioPlayerHandler = AudioPlayerHandler(
        handler: LocalFileHandler(),
        updateTimeInterval: UpdateTimeInterval()
    )
    
    private func configureVolumeSlider() {
        let volumeView = MPVolumeView(frame: volumeSliderView.bounds)
        volumeSliderView.addSubview(volumeView)
    }
    
    private func setButton(enable: Bool) {
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
        audioPlayerHandler.seek(to: -5.0)
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.seek(to: 5.0)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        inPlayMode.toggle()
        audioPlayerHandler.playOrPause()
        if inPlayMode {
            self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
        progressTimer = Timer.scheduledTimer(
            timeInterval: 0.05,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        currentPlayTimeLabel.text = audioPlayerHandler.currentTime
        playProgressBar.progress = audioPlayerHandler.playerProgress
        if !audioPlayerHandler.isPlaying {
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            progressTimer?.invalidate()
        }
    }
}
