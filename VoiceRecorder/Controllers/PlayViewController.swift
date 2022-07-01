//
//  PlayViewController.swift
//  VoiceRecorder
//

import UIKit
import AVKit
import MediaPlayer

class PlayViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var voiceChangeSegment: UISegmentedControl!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - UI Components
    private lazy var mpVolumeView = MPVolumeView()
    
    // MARK: - Properties
    var recordFile: RecordModel?
    var player: AudioPlayer?
    var isPlay = false
    
    let engine = AVAudioEngine()
    let audioPlayer = AVAudioPlayerNode()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupMPVolumeView()
        setUpPlayer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelPlaying()
    }
    
    // MARK: - @IBAction
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        player?.seek(-5)
        
    }
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        player?.seek(5)
    }
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            engine.stop()
            audioPlayer.pause()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            try! play()
        }
        isPlay = !isPlay
    }
    @IBAction func selectVoice(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print(sender.selectedSegmentIndex)
            pitchControl.pitch = 0.0
        case 1:
            print(sender.selectedSegmentIndex)
            pitchControl.pitch = 0.0
            pitchControl.pitch += 800
        case 2:
            print(sender.selectedSegmentIndex)
            pitchControl.pitch = 0.0
            pitchControl.pitch -= 800
        default:
            break
        }
    }
    
}

// MARK: - Methods
private extension PlayViewController {
    func cancelPlaying() {
        player = nil
    }
    func configureUI() {
        guard let recordFile = recordFile else { return }
        dateTitleLabel.text = String(recordFile.name.dropLast(4))
    }
    
    func setUpPlayer() {
        guard let recordFile = recordFile else { return }
        player = recordFile.audioPlayer
        player?.didFinish = {
            self.player?.stop()
            self.playButton.setImage(Icon.play.image, for: .normal)
            self.isPlay = false
        }
    }
    func setupMPVolumeView() {
        volumeView.addSubview(mpVolumeView)
        
        mpVolumeView.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeView.leadingAnchor.constraint(equalTo: volumeView.leadingAnchor).isActive = true
        mpVolumeView.topAnchor.constraint(equalTo: volumeView.topAnchor).isActive = true
        mpVolumeView.trailingAnchor.constraint(equalTo: volumeView.trailingAnchor).isActive = true
        mpVolumeView.bottomAnchor.constraint(equalTo: volumeView.bottomAnchor).isActive = true
        
        mpVolumeView.setRouteButtonImage(UIImage(), for: .normal)
        mpVolumeView.showsVolumeSlider = true
    }
        
    func play() throws {
        let audioFile = try AVAudioFile(forReading: Bundle.main.url(forResource: "1", withExtension: "mp3")!)
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        audioPlayer.scheduleFile(audioFile, at: nil)
        try engine.start()
        audioPlayer.play()
    }
}
