//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    @IBOutlet weak var cutOffSlider: UISlider!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    private lazy var audioRecorder = try! AVAudioRecorder(url: fileName, settings: [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320_000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44_100.0
    ])
    var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private lazy var fileName = fileURL.appendingPathComponent("\(UUID().uuidString).m4a")
    var isRecord = false
    var isPlay = false
//    var progressTimer : Timer!
    
    var recordingSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
        audioRecorder.prepareToRecord()
        
        recordTimeLabel.text = "Press the record button"
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        print(fileName)
        if isRecord {
            sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            audioRecorder.stop()
        } else {
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
            audioRecorder.record()
        }
        isRecord = !isRecord
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {

        if isPlay {
            sender.setImage(UIImage(systemName: "play"), for: .normal)
            audioPlayer?.stop()
        } else {
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileName)
                guard let sound = audioPlayer else { return }
                print(fileName)
                sound.volume = 1.0
                sound.prepareToPlay()
                sound.play()
            } catch {
                recordTimeLabel.text = "The recording file doesn't exist. Press the record button"
            }
        }
        isPlay = !isPlay
        
    }
    
    
    
    func requestRecord() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("allowed record")
                    } else {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        } catch {
            print(" failed to record!")
        }
    }
}
