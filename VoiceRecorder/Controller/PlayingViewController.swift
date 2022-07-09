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
    
    @IBOutlet weak var waveFormView: DrawWaveform!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var soundPitchControl: UISegmentedControl!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var totalPlayTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    private var progressTimer: Timer?
    private var inPlayMode: Bool = false
    var selectedFileInfo: RecordModel?
    var startPoint = CGPoint(x: 0.0, y: 0.0)
    var movePoint = 0.0
    
    var positionBar = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 150))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let fileInfo = selectedFileInfo else { return }
        self.fileNameLabel.text = fileInfo.recordFileName
        self.totalPlayTimeLabel.text = fileInfo.recordTime
        self.currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        audioPlayerHandler.selectPlayFile(self.fileNameLabel.text)
        positionBar.backgroundColor = .black
        waveFormView.addSubview(positionBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayerHandler.stop()
        progressTimer?.invalidate()
    }
    
    private let audioPlayerHandler = AudioPlayerHandler(
        localFileHandler: LocalFileHandler(),
        timeHandler: TimeHandler()
    )
    
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
        audioPlayerHandler.skip(to: -5.0)
        movePoint = 300 * CGFloat(audioPlayerHandler.progress)
        positionBar.frame = CGRect(x: movePoint, y: 0, width: 1, height: 150)
        if movePoint <= 0 {
            positionBar.frame = CGRect(x: 0, y: 0, width: 1, height: 150)
        }
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
    }
    
    @IBAction func goForwardButtonTapped(_ sender: UIButton) {
        audioPlayerHandler.skip(to: 5.0)
        movePoint = 300 * CGFloat(audioPlayerHandler.progress)
        positionBar.frame = CGRect(x: movePoint, y: 0, width: 1, height: 150)
        if movePoint >= 300 {
            positionBar.frame = CGRect(x: 300, y: 0, width: 1, height: 150)
        }
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        inPlayMode.toggle()
       
        if inPlayMode {
            if audioPlayerHandler.isfinished {
                movePoint = 0
                positionBar.frame = CGRect(x: 0, y: 0, width: 1, height: 150)
            }
            if progressTimer != nil {
                progressTimer?.invalidate()
            }
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                 target: self,
                                                 selector: #selector(updateProgress),
                                                 userInfo: nil, repeats: true)
            audioPlayerHandler.play()
        }else {
            audioPlayerHandler.pause()
        }
        
    }
    
    @objc func updateProgress() {
        currentPlayTimeLabel.text = audioPlayerHandler.currentPlayTime
        if !audioPlayerHandler.isPlaying {
            inPlayMode = false
            self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
        } else {
            movePoint = 300 * CGFloat(audioPlayerHandler.progress)
            positionBar.frame = CGRect(x: movePoint, y: 0, width: 1, height: 150)
            self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        audioPlayerHandler.changeVolume(to: sender.value)
    }
}
