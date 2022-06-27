//
//  RecordDetailViewController.swift
//  VoiceRecorder
//
//  Created by BH on 2022/06/27.
//

import UIKit
import AVFoundation

class RecordDetailViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet weak var recordWaveView: UIView!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var recordProgressBar: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    let readyToRecordButtonImage = UIImage(systemName: "record.circle")
    let recordingButtonImage = UIImage(systemName: "record.circle.fill")
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Methods
    func setupAudioRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            recordingSession?.requestRecordPermission({ [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        // TODO: 권한을 못받은 경우
                        // Alert 창이 나오고, '확인'을 누르면 '권한 설정' 페이지로 이동
                    }
                }
            })
            
        } catch let error {
            // TODO: 에러 핸들링
            print(error.localizedDescription)
        }
    }
    
    func loadRecordingUI() {
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder?.delegate = self
            audioRecorder?.record()

            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setImage(readyToRecordButtonImage, for: .normal)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    
    // MARK: - IBActions
    
    @IBAction func controlRecordProgressBar(_ sender: UISlider) {
    }
    
    @IBAction func controlRecordButton(_ sender: UIButton) {
        if audioRecorder == nil {
            setupAudioRecorder()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func controlBackButton(_ sender: UIButton) {
    }
    
    @IBAction func controlPlayButton(_ sender: UIButton) {
    }
    
    @IBAction func controlNextButton(_ sender: UIButton) {
    }
    
    
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioRecorderDelegate {
    
}
