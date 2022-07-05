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
    var isPlay = false
    var localFileManager: LocalFileManager?
    
    let engine = AudioEngine()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpLocalFileManger()
        setupMPVolumeView()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelPlaying()
    }
    
    // MARK: - @IBAction
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        engine.seek(to: -3)
    }
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        engine.seek(to: 3)
    }
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            engine.pause()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            setupEngine()
            engine.play()
        }
        isPlay = !isPlay
    }
    @IBAction func selectVoice(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print(sender.selectedSegmentIndex)
            engine.setPitch(0.0)
        case 1:
            print(sender.selectedSegmentIndex)
            engine.setPitch(800.0)
        case 2:
            print(sender.selectedSegmentIndex)
            engine.setPitch(-800.0)
        default:
            break
        }
    }
}

// MARK: - Methods
private extension PlayViewController {
    func cancelPlaying() {
        engine.stop()
    }
    func configureUI() {
        guard let recordFile = recordFile else { return }
        dateTitleLabel.text = String(recordFile.name.dropLast(4))
    }
    func setupEngine() {
        guard let recordFile = recordFile,
              let eqString = recordFile.metaData[MetaData.eq.key] else { return }
        let gains = eqString.split(separator: " ").map { String($0) }.map { Float($0) ?? 0.0 }
                
        engine.url = localFileManager?.audioPath
        engine.gains = gains
        try! engine.setupEngine()
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
    func setUpLocalFileManger() {
        guard let recordFile = recordFile else { return }
        localFileManager = LocalFileManager(recordModel: recordFile)
        localFileManager?.downloadToLocal()
    }
}
