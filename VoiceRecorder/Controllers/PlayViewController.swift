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
    @IBOutlet weak var playerTimeLabel: UILabel!
    @IBOutlet weak var graphView: GraphView!
    
    // MARK: - UI Components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var recordFile: RecordModel?
    private var isPlay = false
    private var localFileManager: LocalFileManager?
    private var playerTimer: Timer?
    
    private let engine = AudioEngine()
    
    private var decibels = [Int]()
    private var i = 0
    private var stepDuration = 0.05
    private var buffer = LastNItemsBuffer<CGFloat>.init(count: 100)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        activityIndicator.startAnimating()
        setUpLocalFileManger { error in
            if error != nil {
                UIAlertController.showOKAlert(
                    self,
                    title: "ERROR",
                    message: "로컬 저장에 실패 했습니다.",
                    handler: { _ in
                        self.dismiss(animated: true)
                    }
                )
            }
            self.setupEngine { error in
                if error != nil {
                    UIAlertController.showOKAlert(
                        self,
                        title: "ERROR",
                        message: "파일 정보를 불러오는데 실패했습니다.",
                        handler: nil
                    )
                }
                self.getDecibel { error in
                    if error != nil {
                        UIAlertController.showOKAlert(
                            self,
                            title: "ERROR",
                            message: "파일 정보를 불러오는데 실패했습니다.",
                            handler: nil
                        )
                    }
                    DispatchQueue.main.async {
                        self.updateViewDidFinishEngineSetup()
                    }
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelPlaying()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        buffer.forceToValue(0.0)
        graphView.points = buffer
    }
    
    // MARK: - @IBAction
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        engine.skip(forwards: false)
        graphView.reset()
        i -= 500
        if i < 0 {
            i = 0
        }
    }
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        engine.skip(forwards: true)
        graphView.reset()
        i += 500
        if i >= decibels.count {
            i = decibels.count - 1
        }
    }
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(.play)
            engine.pause()
            playerTimer?.invalidate()
        } else {
            graphView.drawBarGraph = true
            sender.setImage(.pauseFill)
            engine.play()
            playerTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updatePlayerTimer),
                userInfo: nil,
                repeats: true
            )
        }
        isPlay = !isPlay
    }
    @IBAction func selectVoice(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            engine.setPitch(0.0)
        case 1:
            engine.setPitch(800.0)
        case 2:
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

// MARK: - @objc Methods
private extension PlayViewController {
    @objc func updatePlayerTimer() {
        if engine.isFinish() {
            playButton.setImage(.play)
            isPlay = false
            playerTimer?.invalidate()
            engine.stop()
            engine.currentPosition = 0
            engine.seekFrame = 0
            i = 0
            playerTimeLabel.text = "\(engine.duration.toStringTimeFormat)"
            guard (try? engine.setupEngine()) != nil else { return }
        } else {
            playerTimeLabel.text = "\(engine.getCurrentTime().toStringTimeFormat)"
        }
        
        if i < decibels.count {
            let value = decibels[i]
            if value > 160 {
                self.graphView.animateNewValue(
                    CGFloat(graphView.maxValue),
                    duration: self.stepDuration
                )
            } else {
                self.graphView.animateNewValue(
                    CGFloat(value),
                    duration: self.stepDuration
                )
            }
            i += 1
        }
    }
}

// MARK: - Methods
private extension PlayViewController {
    func cancelPlaying() {
        engine.stop()
    }
    func updateViewDidFinishEngineSetup() {
        self.playerTimeLabel.text = self.engine.duration.toStringTimeFormat
        self.activityIndicator.stopAnimating()
        self.enableButton()
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
    func setupEngine(didFinish completion: @escaping (Error?) -> Void) {
        guard let recordFile = recordFile,
              let eqString = recordFile.metaData[MetaData.eq.key] else { return }
        let gains = eqString.split(separator: " ").map { String($0) }.map { Float($0) ?? 0.0 }
        
        engine.url = localFileManager?.audioPath
        engine.gains = gains
        do {
            try engine.setupEngine()
            completion(nil)
        } catch {
            completion(error)
        }
        guard (try? engine.setupEngine()) != nil else { return }
    }
    func setUpLocalFileManger(didFinish completion: @escaping (Error?) -> Void) {
        guard let recordFile = recordFile else { return }
        localFileManager = LocalFileManager(recordModel: recordFile)
        localFileManager?.downloadToLocal { error in
            if error != nil {
                completion(error)
                return
            }
            completion(nil)
            return
        }
    }
    
    func getDecibel(completion: @escaping (Error?) -> Void) {
        guard let urlString = recordFile?.metaData[MetaData.decibelDataURL.key],
              let url = URL(string: urlString) else { return }
        
        Network().fetchData(url: url) { result in
            switch result {
            case .success(let data):
                let decibelArr = JSONDecoder.decode([Int].self, data: data) ?? []
                self.decibels = decibelArr
                completion(nil)
                return
            case .failure(let error):
                completion(error)
                return
            }
        }
    }
}
