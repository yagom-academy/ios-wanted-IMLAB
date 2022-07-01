//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation
import FirebaseStorage

class RecordViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var cutOffSlider: UISlider!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playBackwardButton: UIButton!
    @IBOutlet weak var playForwardButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: RecordViewControllerDelegate?
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var fileName: URL?
    private var recordDate: String?
    private let recorderSetting: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320_000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44_100.0
    ]
    private var recordingSession = AVAudioSession.sharedInstance()
    private var audioPlayer: AVAudioPlayer?
    private var isRecord = false
    private var isPlay = false
    private var progressTimer: Timer?
    private var counter = 0.0
    private var currentPlayTime = 0.0
    
    private let player = AudioPlayer()
    private let recorder = AudioRecorder()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
        setupButton(isHidden: true)
        setupAudioRecorder()
        player.didFinish = {
            self.isPlay = false
            self.currentPlayTime = 0.0
            self.counter = 0.0
            self.progressTimer?.invalidate()
            self.playButton.setImage(Icon.play.image, for: .normal)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelRecording()
    }
    
    // MARK: - @IBAction
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        if isRecord {
            sender.setImage(Icon.circleFill.image, for: .normal)
            setupButton(isHidden: false)
            endRecord()
            guard let data = recorder.data else { return }
            uploadFile(data, fileName: recordDate ?? "")
            
        } else {
            sender.setImage(Icon.circle.image, for: .normal)
            recorder.record()
            progressTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
        }
        isRecord = !isRecord
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        player.seek(-5)
        counter = player.currentTime
        currentPlayTime = player.currentTime
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        player.seek(5)
        counter = player.currentTime
        currentPlayTime = player.currentTime
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            progressTimer?.invalidate()
            currentPlayTime = player.currentTime
            player.stop()
        } else {
            player.url = fileName
            player.setupPlayer()
            player.currentTime = currentPlayTime
            player.play()
            
            progressTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
            sender.setImage(Icon.pauseFill.image, for: .normal)
            if currentPlayTime >= player.duration {
                currentPlayTime = 0.0
                counter = 0
            }
        }
        isPlay = !isPlay
    }
}

// MARK: - @objc Methods
private extension RecordViewController {
    @objc func update() {
        counter += 0.01
        if let audioPlayer = audioPlayer {
            if counter > audioPlayer.duration {
                counter = audioPlayer.duration
            }
        }
        recordTimeLabel.text = "\(counter.toString)"
    }
}

// MARK: - Methods
private extension RecordViewController {
    func setupAudioRecorder() {
        recordDate = Date.now.dateToString
        fileName = fileURL.appendingPathComponent("\(recordDate ?? "").m4a")
        guard let fileName = fileName else { return }
        recorder.path = fileName
        recorder.settings = recorderSetting
        recorder.setupAudioRecorder()
    }
    
    func requestRecord() {
        recordingSession.requestRecordPermission({ allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("allowed record")
                } else {
                    self.openSetting()
                }
            }
        })
    }
    
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setupButton(isHidden: Bool) {
        playButton.isHidden = isHidden
        playBackwardButton.isHidden = isHidden
        playForwardButton.isHidden = isHidden
        if isHidden == false {
            recordButton.isHidden = true
        }
    }
    
    func cancelRecording() {
        recorder.stop()
        recorder.deleteRecording()
        player.stop()
    }
    
    func endRecord() {
        recorder.stop()
        progressTimer?.invalidate()
        counter = 0.0
    }
    
    func uploadFile(_ data: Data, fileName: String) {
        StorageManager.shared.upload(data: data, fileName: fileName) { result in
            switch result {
            case .success(_):
                print("저장 성공🎉")
                self.delegate?.didFinishRecord()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🌡🌡")
            }
        }
    }
    
}
