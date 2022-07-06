//
//  PlayViewController.swift
//  VoiceRecorder
//

import UIKit
import AVKit

class PlayViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var voiceChangeSegment: UISegmentedControl!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var playForwardButton: UIButton!
    @IBOutlet weak var volumeTextLabel: UILabel!
    
    // MARK: - UI Components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var recordFile: RecordModel?
    private var isPlay = false
    private var localFileManager: LocalFileManager?
    
    private let engine = AudioEngine()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        activityIndicator.startAnimating()
        setUpLocalFileManger {
            self.setupEngine {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.enableButton()
                }
            }
        }
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
            sender.setImage(.play)
            engine.pause()
        } else {
            sender.setImage(.pauseFill)
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
    @IBAction func changeVolume(_ sender: UISlider) {
        engine.changeVolume(sender.value)
        volumeTextLabel.text = "volume \(Int(sender.value * 100))%"
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
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func enableButton() {
        playButton.isEnabled = true
        playBackButton.isEnabled = true
        playForwardButton.isEnabled = true
    }
    func setupEngine(didFinish completion: @escaping () -> Void) {
        guard let recordFile = recordFile,
              let eqString = recordFile.metaData[MetaData.eq.key] else { return }
        let gains = eqString.split(separator: " ").map { String($0) }.map { Float($0) ?? 0.0 }
                
        engine.url = localFileManager?.audioPath
        engine.gains = gains
        do {
            try engine.setupEngine()
            completion()
        } catch {
            print("ERROR \(error.localizedDescription)🌔")
        }
    }
    func setUpLocalFileManger(didFinish completion: @escaping () -> Void) {
        guard let recordFile = recordFile else { return }
        localFileManager = LocalFileManager(recordModel: recordFile)
        localFileManager?.downloadToLocal { completion() }
    }
}
