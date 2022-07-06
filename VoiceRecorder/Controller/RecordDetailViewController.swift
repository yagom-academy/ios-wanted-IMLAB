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
    
    @IBOutlet weak var waveView: UIView!
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
    
    let readyToRecordButtonImage = UIImage(systemName: "circle.fill")
    let recordingButtonImage = UIImage(systemName: "square.fill")
    
    let playButtonImage = UIImage(systemName: "play.fill")
    let pauseButtonImage = UIImage(systemName: "pause.fill")
    
    var currentFileName : String?
    
    var timer : Timer?
    lazy var pencil = UIBezierPath(rect: waveView.bounds)
    lazy var firstPoint = CGPoint(x: waveView.bounds.midX, y: waveView.bounds.midY)
    lazy var jump : CGFloat = (firstPoint.x)/200
    let waveLayer = CAShapeLayer()
    var traitLength : CGFloat!
    var start : CGPoint!
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsStackView.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if audioRecorder != nil {
            // 오디오 중지
            writeWaves(0, false)
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
//            enableBuiltInMic()
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
        pencil.removeAllPoints()
        waveLayer.removeFromSuperlayer()
        writeWaves(0, false)
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record() // 이것의 상태를 조건으로 다른 것 control하는 듯
            audioRecorder?.isMeteringEnabled = true
            durationLabel.text = "녹음중 .."
            buttonsStackView.isHidden = true
            recordButton.setImage(recordingButtonImage, for: .normal)
        } catch {
            finishRecording(success: false, audioFileURL)
        }
        var translationX = 0.0

        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            UIView.animate(withDuration: 0.01, delay: 0, options: [.curveLinear]) {
                self.waveView.transform = CGAffineTransform(translationX: translationX, y: 0)
                translationX -= self.jump
            }
            self.audioRecorder?.updateMeters()
            // write waveforms
            let averagePower = self.audioRecorder?.averagePower(forChannel: 0)
            self.writeWaves(averagePower ?? 0.0, true)
        }
    }
    
    func changeViewToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: waveView.bounds.size)
        return renderer.image {context in
            waveView.layer.render(in: context.cgContext)
        }
    }

    func finishRecording(success: Bool, _ url: URL?) {
        writeWaves(0, false)
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
            // 여기서 그림이랑 재생시간 계속 리로드
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
    
    private func enableBuiltInMic() {
        // Get the shared audio session.
        let session = AVAudioSession.sharedInstance()
        // Find the built-in microphone input.
        guard let availableInputs = session.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            print("The device must have a built-in microphone.")
            return
        }
        // Make the built-in microphone input the preferred input.
        do {
            try session.setPreferredInput(builtInMicInput)
        } catch {
            print("Unable to set the built-in mic as the preferred input.")
        }
    }
    
    func writeWaves(_ input: Float, _ bool : Bool) {
        if !bool {
            start = firstPoint
            if timer != nil || audioRecorder != nil {
                timer?.invalidate()
                audioRecorder?.stop()
                audioRecorder = nil
            }
            
            return
        } else {
            if input < -55 {
                traitLength = 0.2
            } else if input < -40 && input > -55 {
                traitLength = (CGFloat(input) + 56) / 3
            } else if input < -20 && input > -40 {
                traitLength = (CGFloat(input) + 41) / 2
            } else if input < -10 && input > -20 {
                traitLength = (CGFloat(input) + 21) * 5
            } else {
                traitLength = (CGFloat(input) + 20) * 3
            }
            
            pencil.lineWidth = jump
            
            pencil.move(to: start)
            pencil.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
            
            pencil.move(to: start)
            pencil.addLine(to: CGPoint(x: start.x, y: start.y - traitLength))
            
            waveLayer.strokeColor = UIColor.gray.cgColor
            
            waveLayer.path = pencil.cgPath
            waveLayer.fillColor = UIColor.clear.cgColor
            
            waveLayer.lineWidth = jump
            
            waveView.layer.addSublayer(waveLayer)
            waveLayer.contentsCenter = waveView.frame
            
            waveView.setNeedsDisplay()
            
            start = CGPoint(x: start.x + jump, y: start.y)
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
