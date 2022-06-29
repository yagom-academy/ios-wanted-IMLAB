//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation
import FirebaseStorage

protocol RecordViewControllerDelegate: AnyObject {
    func didFinishRecord()
}

class RecordViewController: UIViewController {
    
    @IBOutlet weak var cutOffSlider: UISlider!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playBackwardButton: UIButton!
    @IBOutlet weak var playForwardButton: UIButton!
    
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
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession = AVAudioSession.sharedInstance()
    private var audioPlayer: AVAudioPlayer?
    
    var isRecord = false
    var isPlay = false
    var progressTimer: Timer?
    var counter = 0.0
    var currentPlayTime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        if isRecord {
            progressTimer?.invalidate()
            counter = 0.0
            sender.setImage(Icon.circleFill.image, for: .normal)
            audioRecorder?.stop()
            let data = try! Data(contentsOf: audioRecorder!
                .url)
            
            StorageManager().upload(data: data, fileName: recordDate ?? "") { result in
                switch result {
                case .success(_):
                    print("저장 성공🎉")
                    self.delegate?.didFinishRecord()
                case .failure(let error):
                    print("ERROR \(error.localizedDescription)🌡🌡")
                }
            }
        } else {
            sender.setImage(Icon.circle.image, for: .normal)
            setupAudioRecorder()
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
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
    
    @objc func update() {
        counter += 0.01
        recordTimeLabel.text = "\(counter.toString)"
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0.0) - 5.0
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        audioPlayer?.currentTime = (audioPlayer?.currentTime ?? 0.0) + 5.0
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            currentPlayTime = audioPlayer?.currentTime ?? 0.0
            progressTimer?.invalidate()
            audioPlayer?.stop()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            playAudio()
            
            progressTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
            setupAudioPlayer()
        }
        isPlay = !isPlay
    }
}

extension RecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlay = false
        currentPlayTime = 0.0
        counter = 0.0
        progressTimer?.invalidate()
        playButton.setImage(Icon.play.image, for: .normal)
    }
}

private extension RecordViewController {
    func setupAudioPlayer() {
        audioPlayer?.delegate = self
    }
    func playAudio() {
        do {
            guard let fileName = fileName else { return }
            audioPlayer = try AVAudioPlayer(contentsOf: fileName)
            audioPlayer?.volume = 1.0
            audioPlayer?.currentTime = currentPlayTime
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            recordTimeLabel.text = "The recording file doesn't exist. Press the record button"
        }
    }
    func setupAudioRecorder() {
        do {
            recordDate = Date.now.dateToString
            fileName = fileURL.appendingPathComponent("\(recordDate ?? "").m4a")
            guard let fileName = fileName else { return }
            audioRecorder = try AVAudioRecorder(url: fileName, settings: recorderSetting)
        } catch {
            print("ERROR \(error.localizedDescription)")
        }
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
}
