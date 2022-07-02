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
    
    let engine = AudioEngine()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupMPVolumeView()
        setUpPlayer()
        download(url: recordFile!.url, name: recordFile!.name)
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
            engine.pause()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            engine.url = getAudioFilePath(name: recordFile!.name)
            try! engine.setupEngine()
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
    func download(url: URL, name: String) {
        let fileManager = FileManager.default
        let filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]        
        let audioPath = filePath.appendingPathComponent(name)
        do {
            let data = try Data(contentsOf: url)
            try data.write(to: audioPath)
        } catch {
            print("다운로드 에러")
        }
    }
    func getAudioFilePath(name: String) -> URL {
        let fileManager = FileManager.default
        let filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioPath = filePath.appendingPathComponent(name)
        
        return audioPath
    }
}
