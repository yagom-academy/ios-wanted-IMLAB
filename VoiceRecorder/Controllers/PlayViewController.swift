//
//  PlayViewController.swift
//  VoiceRecorder
//

import UIKit
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
            player?.stop()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            player?.play()
        }
        isPlay = !isPlay
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
}
