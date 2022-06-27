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
    private lazy var fileName = fileURL.appendingPathComponent("\(UUID().uuidString).mp4")
    var isRecord = false
    
    var recordingSession: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestRecord()
        audioRecorder.prepareToRecord()
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
        let audioPlayer = try? AVAudioPlayer(contentsOf: fileName)
        audioPlayer?.volume = 1.0
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
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
                // failed to record!
            }
        }
}
