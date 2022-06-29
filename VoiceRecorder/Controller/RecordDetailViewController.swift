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
    
    // MARK: - Enums
    
    enum RecordFileString {
        static var fileName = "recording"
        static let fileExtension = ".m4a"
        static var fileFullName = "recording\(fileName)\(fileExtension)"
    }
    
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
    
    let storage = Storage.storage()
    
    var audioFileURL : URL?
    
    // wave test
    var pencil : UIBezierPath?
    var firstPoint : CGPoint?
    var jump : CGFloat?
    var waveLayer : CAShapeLayer?
    var traitLength : CGFloat!
    var start : CGPoint!
        
    let readyToRecordButtonImage = UIImage(systemName: "record.circle")
    let recordingButtonImage = UIImage(systemName: "record.circle.fill")
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWave()
    }
    
    // MARK: - Methods
    
    func initWave() {
        pencil = UIBezierPath(rect: recordWaveView.bounds)
        firstPoint = CGPoint(x: 6, y: (recordWaveView.bounds.midY))
        jump = (recordWaveView.bounds.width - (firstPoint!.x * 2)) / 200
        waveLayer = CAShapeLayer()
    }
    
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
    
    func makeFileName() -> String {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "_yyyy_MM_dd_HH:mm:ss"
        let currentDateString = formatter.string(from: Date())
        return currentDateString
    }
    
    func writeWaves(_ input : Float, _ bool : Bool) {
        if !bool {
            start = firstPoint
            return
        } else {
            if input < -55 {
                traitLength = 0.2
            } else if input < -40 && input > -55 {
                traitLength = (CGFloat(input) * 56) / 3
            } else if input < -20 && input > -40 {
                traitLength = (CGFloat(input) * 41) / 2
            } else if input < -10 && input > -20 {
                traitLength = (CGFloat(input) * 21) * 5
            } else {
                traitLength = (CGFloat(input) * 20) * 4
            }
            
            pencil?.lineWidth = jump!
            
            pencil?.move(to: start)
            pencil?.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
            
            pencil?.move(to: start)
            pencil?.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
            
            waveLayer?.strokeColor = UIColor.black.cgColor
            
            waveLayer?.path = pencil?.cgPath
            waveLayer?.fillColor = UIColor.clear.cgColor
            
            waveLayer?.lineWidth = jump!
            
            recordWaveView.layer.addSublayer(waveLayer!)
            waveLayer?.contentsCenter = recordWaveView.frame
            
            recordWaveView.setNeedsDisplay()
            
            start = CGPoint(x: start.x + jump!, y: start.y)

        }
        
    }
        
    func startRecording() {
        RecordFileString.fileName += makeFileName()
        // 파일 생성
        print(RecordFileString.fileFullName)
        audioFileURL = getDocumentsDirectory().appendingPathComponent(RecordFileString.fileFullName)
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(RecordFileString.fileFullName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        pencil?.removeAllPoints()
        waveLayer?.removeFromSuperlayer()
        writeWaves(0, false)

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings) // force unwrapping
//            audioRecorder?.delegate = self
            audioRecorder?.record() // 이것의 상태를 조건으로 다른 것 control하는 듯
            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            self.writeWaves((self.audioRecorder?.averagePower(forChannel: 0))!, true)
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
        guard let url = url else {
            return
        }

        let storageRef = storage.reference()
                
        let riversRef = storageRef.child("recording/\(RecordFileString.fileName)")
        
        riversRef.putFile(from: url) // force unwrapping
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) // 해당 dir에 url
        return paths[0] // 어떤 것들이 담겨있는지?
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
    }
    
    @IBAction func controlNextButton(_ sender: UIButton) {
    }
    
    
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioRecorderDelegate {
    
}
