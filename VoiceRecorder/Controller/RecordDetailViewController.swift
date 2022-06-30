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
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
        
    var audioFileURL : URL?
            
    let readyToRecordButtonImage = UIImage(systemName: "record.circle")
    let recordingButtonImage = UIImage(systemName: "record.circle.fill")
    
    let playButtonImage = UIImage(systemName: "play.fill")
    let pauseButtonImage = UIImage(systemName: "pause.fill")
    
    // about play
    var player : AVAudioPlayer?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if audioRecorder != nil {
            // 오디오 중지
            audioRecorder?.stop()
            audioRecorder = nil
            // 로컬에 생성된 파일 삭제
            if let audioFileURL = audioFileURL {
                do {
                    print(audioFileURL)
                    try FileManager.default.removeItem(at: audioFileURL)
                } catch {
                    print(error)
                }
            }
        } else {
            print("close")
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
    
    func loadRecordingUI() {

    }
        
    func startRecording() {
        let fileName = DataFormatter.makeFileName()
        FireStorageManager.RecordFileString.Path.fileName = fileName
        // 파일 생성
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
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
            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            finishRecording(success: false, audioFileURL)
        }
    }
    
    func finishRecording(success: Bool, _ url: URL?) {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setImage(readyToRecordButtonImage, for: .normal)
        uploadRecordDataToFirebase(url)
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

    // about play
    func initPlay() {
        if let findUrl = audioFileURL {
            do {
                player = try AVAudioPlayer(contentsOf: findUrl)
                player?.delegate = self
                player?.prepareToPlay() // 실제 호출과 기기의 플레이 간의 딜레이를 줄여줌
            }
            catch {
                print(error)
            }
        }
    }
    
    func playSound() {
        if player?.isPlaying == false {
            player?.play()
            playButton.setImage(pauseButtonImage, for: .normal)
        }
        else {
            player?.pause()
            player?.prepareToPlay()
            playButton.setImage(playButtonImage, for: .normal)
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
    
    @IBAction func controlBackButton(_ sender: UIButton) {
    }
    
    @IBAction func controlPlayButton(_ sender: UIButton) {
        if player != nil {
            playSound()
        } else {
            initPlay()
        }
    }
    
    @IBAction func controlNextButton(_ sender: UIButton) {
    }
    
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(playButtonImage, for: .normal)
    }
}
