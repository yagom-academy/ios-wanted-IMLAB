//
//  RecordDetailViewController.swift
//  VoiceRecorder
//
//  Created by BH on 2022/06/27.
//

import UIKit
import AVFoundation
import FirebaseStorage

class RecordDetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var recordWaveView: UIView!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var recordProgressBar: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var player : AVAudioPlayer?
        
    var audioFileURL : URL?
            
    let readyToRecordButtonImage = UIImage(systemName: "record.circle")
    let recordingButtonImage = UIImage(systemName: "record.circle.fill")
    
    let playButtonImage = UIImage(systemName: "play.fill")
    let pauseButtonImage = UIImage(systemName: "pause.fill")
    
    // test
    var currentFileName : String?
    
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsStackView.isHidden = true
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if audioRecorder != nil {
            // 오디오 중지
            audioRecorder?.stop()
            audioRecorder = nil
            // 로컬에 생성된 파일 삭제
            if let audioFileURL = audioFileURL {
                do {
                    try FileManager.default.removeItem(at: audioFileURL)
                } catch {
                    print(error)
                }
            }
            currentFileName = nil
        }
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
                        self.showSettingViewController()
                    }
                }
            })
        } catch let error {
            // TODO: 에러 핸들링
            print(error.localizedDescription)
        }
    }
        
    func startRecording() {
        if let audioFileURL = audioFileURL {
            do {
                try FileManager.default.removeItem(at: audioFileURL)
                if let currentFileName = currentFileName {
                    FireStorageManager.shared.deleteItem(currentFileName)
                }
            } catch {
                print(error)
            }
        }
        let fileName = DataFormatter.makeFileName()
        FireStorageManager.RecordFileString.Path.fileName = fileName
        currentFileName = FireStorageManager.RecordFileString.fileFullName
        // 파일 생성
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        audioFileURL = fileURL.appendingPathComponent("\(FireStorageManager.RecordFileString.fileFullName)\(FireStorageManager.RecordFileString.contentType.audio)")
        let audioFileURL = fileURL.appendingPathComponent("\(FireStorageManager.RecordFileString.fileFullName)\(FireStorageManager.RecordFileString.contentType.audio)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record() // 이것의 상태를 조건으로 다른 것 control하는 듯
            durationLabel.text = "녹음중 .."
            buttonsStackView.isHidden = true
            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            finishRecording(success: false, audioFileURL)
        }
    }
    
    func finishRecording(success: Bool, _ url: URL?) {
        audioRecorder?.stop()
        audioRecorder = nil
        showDuration(url)
        uploadRecordDataToFirebase(url)
        recordButton.setImage(readyToRecordButtonImage, for: .normal)
        buttonsStackView.isHidden = false
    }
    
    func showDuration(_ url: URL?) {
        var durationTime: String = ""
        guard let url = url else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            if let duration = player?.duration {
                durationTime = duration.minuteSecondMS
                durationLabel.text = durationTime
            }
        } catch {
            print("<finishRecording Error> -\(error.localizedDescription)")
        }
    }
    
    func uploadRecordDataToFirebase(_ url: URL?) {
        FireStorageManager.shared.uploadData(url)
    }
    
    func showSettingViewController() {
        let alert = UIAlertController(title: "접근권한", message: "마이크 접근권한이 필요합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                      return
                  }
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }))
        present(alert, animated: true, completion: nil)
    }

    func playSound() {
        if player?.isPlaying == false {
            player?.play()
            playButton.setImage(pauseButtonImage, for: .normal)
            recordButton.isHidden = true
        } else {
            player?.pause()
            player?.prepareToPlay()
            playButton.setImage(playButtonImage, for: .normal)
            recordButton.isHidden = false
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func controlRecordProgressBar(_ sender: UISlider) {
    }
    
    @IBAction func controlRecordButton(_ sender: UIButton) {
        if audioRecorder == nil {
            setupAudioRecorder()
        } else {
            finishRecording(success: true, audioFileURL)
        }
    }
    
    @IBAction func pressPrevButton(_ sender: UIButton) {
        player?.currentTime -= 5
    }
    
    @IBAction func pressPlayButton(_ sender: UIButton) {
        playSound()
    }
    
    @IBAction func pressNextButton(_ sender: UIButton) {
        player?.currentTime += 5
    }
    
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(playButtonImage, for: .normal)
        recordButton.isHidden = false
    }
}
