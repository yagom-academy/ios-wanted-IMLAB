//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    @IBOutlet weak var cutOffSlider: UISlider!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private lazy var fileName = fileURL.appendingPathComponent("\(UUID().uuidString).m4a")
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
//    var progressTimer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
        setupAudioRecorder()
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        print(fileName)
        if isRecord {
            sender.setImage(Icon.circleFill.image, for: .normal)
            audioRecorder?.stop()
        } else {
            sender.setImage(Icon.circle.image, for: .normal)
            audioRecorder?.record()
        }
        isRecord = !isRecord
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(Icon.play.image, for: .normal)
            audioPlayer?.stop()
        } else {
            sender.setImage(Icon.pauseFill.image, for: .normal)
            playAudio()
        }
        isPlay = !isPlay
    }
}

private extension RecordViewController {
    func playAudio() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileName)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            recordTimeLabel.text = "The recording file doesn't exist. Press the record button"
        }
    }
    func setupAudioRecorder() {
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: recorderSetting)
            audioRecorder?.prepareToRecord()
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
