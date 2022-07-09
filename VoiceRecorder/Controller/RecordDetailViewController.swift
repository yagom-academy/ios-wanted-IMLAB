//
//  RecordDetailViewController.swift
//  VoiceRecorder
//
//  Created by BH on 2022/06/27.
//

import AVFoundation
import UIKit

import FirebaseStorage

class RecordDetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var waveFormCanvasView: UIView!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cutOffFreqSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private var player : AVAudioPlayer?
    
    private var audioFileURL : URL?
    private var imageFileURL : URL?
    
    private let readyToRecordButtonImage = UIImage(systemName: "circle.fill")
    private let recordingButtonImage = UIImage(systemName: "square.fill")
    private let playButtonImage = UIImage(systemName: "play.fill")
    private let pauseButtonImage = UIImage(systemName: "pause.fill")
    
    private var currentFileName : String?
    
    private var timer : Timer?
    private var recordingTimer : Timer?
    
    private var samplerate : Int?
    
    private lazy var pencil = UIBezierPath()
    private lazy var firstPoint = CGPoint(x: waveFormCanvasView.bounds.midX, y: waveFormCanvasView.bounds.midY)
    private lazy var jump : CGFloat = (firstPoint.x)/200
    private let waveLayer = CAShapeLayer()
    private var traitLength : CGFloat!
    private var start : CGPoint!
    var translationX : Double = 0.0
        
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsStackView.isHidden = true
        waveFormCanvasView.frame.size.width = CGFloat(FP_INFINITE)
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
                    print("Error: <RecordDetail viewDidDisappear> -  \(error.localizedDescription)")
                }
            }
            currentFileName = nil
        }
        if currentFileName != nil {
            
        }
    }
    
    // MARK: - Methods
    
    private func setupAudioRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
            try recordingSession?.setActive(true)
            try recordingSession?.setPreferredSampleRate(Double(samplerate ?? 8000))
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
            print("Error: <setupAudioRecorder> -  \(error.localizedDescription)")
        }
    }
    
    private func deleteOriginFile() {
        if let audioFileURL = audioFileURL {
            do {
                try FileManager.default.removeItem(at: audioFileURL)
                if let currentFileName = currentFileName {
                    FireStorageManager.shared.deleteRecording(currentFileName)
                    FireStorageManager.shared.deleteImage(currentFileName)
                }
            } catch {
                print("Error: <delete origin audio file> - \(error.localizedDescription)")
            }
        }
    }
    
    private func startRecording() {
        deleteOriginFile()
        // TODO: fileURL refactoring
        let fileName = DataFormatter.makeFileName()
        FireStorageManager.File.Path.fileName = fileName
        currentFileName = FireStorageManager.File.fileFullName
        // 파일 생성
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        audioFileURL = fileURL.appendingPathComponent("\(FireStorageManager.File.fileFullName)\(FireStorageManager.File.contentType.audio)")
        let audioFileURL = fileURL.appendingPathComponent("\(FireStorageManager.File.fileFullName)\(FireStorageManager.File.contentType.audio)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        
        initDrawingWave()

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record() // 이것의 상태를 조건으로 다른 것 control하는 듯
            audioRecorder?.isMeteringEnabled = true
            buttonsStackView.isHidden = true
            recordButton.setImage(recordingButtonImage, for: .normal)
            cutoffLabel.isHidden = true
            cutOffFreqSegmentedControl.isHidden = true
        } catch {
            print("Error: <start recording> - \(error.localizedDescription)")
        }
        
        drawingWave()
        getRecordingTime()
    }
    
    private func initDrawingWave() {
        pencil.removeAllPoints()
        waveLayer.removeFromSuperlayer()
        writeWaves(0, false)
    }
    
    private func drawingWave() {
        translationX = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            UIView.animate(withDuration: 0.01, delay: 0, options: [.curveLinear]) {
                self.waveFormCanvasView.transform = CGAffineTransform(translationX: self.translationX, y: 0)
                self.translationX -= self.jump
            }
            self.audioRecorder?.updateMeters()
            // write waveforms
            let averagePower = self.audioRecorder?.averagePower(forChannel: 0)
            self.writeWaves(averagePower ?? 0.0, true)
        }
    }

    private func finishRecording(success: Bool, _ url: URL?) {
        writeWaves(0, false)
        showDuration(url)
        uploadRecordDataToFirebase(url)
        captureWaveForm()
        
        // Change UI
        recordButton.setImage(readyToRecordButtonImage, for: .normal)
        buttonsStackView.isHidden = false
        cutoffLabel.isHidden = false
        cutOffFreqSegmentedControl.isHidden = false
    }
    
    func uploadImageToFirebase(_ image : UIImage?) {
        FireStorageManager.shared.uploadImage(image)
    }
    
    
    func captureWaveForm() {
        let size = CGRect(x: waveFormCanvasView.bounds.midX, y: waveFormCanvasView.bounds.minY, width: translationX.magnitude, height: waveFormCanvasView.bounds.height)
        let renderer = UIGraphicsImageRenderer(bounds: size)
        let image = renderer.image { rendererContext in
            waveFormCanvasView.layer.render(in: rendererContext.cgContext)
        }
        uploadImageToFirebase(image)
    }
    
    private func showDuration(_ url: URL?) {
        var durationTime: String = ""
        guard let url = url else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            
            if let duration = player?.duration {
                durationTime = duration.minuteSecond
                recordingTimeLabel.text = durationTime
            }
        } catch {
            print("Error: <finishRecording> - \(error.localizedDescription)")
        }
    }
    
    private func uploadRecordDataToFirebase(_ url: URL?) {
        FireStorageManager.shared.uploadData(url)
    }
    
    private func showSettingViewController() {
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
    
    private func playSound() {
        if player?.isPlaying == false {
            player?.play()
            
            playButton.setImage(pauseButtonImage, for: .normal)
            recordButton.isHidden = true
            cutoffLabel.isHidden = true
            cutOffFreqSegmentedControl.isHidden = true
        } else {
            player?.pause()
            player?.prepareToPlay()
            
            playButton.setImage(playButtonImage, for: .normal)
            recordButton.isHidden = false
            cutoffLabel.isHidden = false
            cutOffFreqSegmentedControl.isHidden = false
        }
    }
    
    private func writeWaves(_ input: Float, _ bool : Bool) {
        if !bool {
            start = firstPoint
            if timer != nil || audioRecorder != nil {
                timer?.invalidate()
                recordingTimer?.invalidate()
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
            
            waveFormCanvasView.layer.addSublayer(waveLayer)
            waveLayer.contentsCenter = waveFormCanvasView.frame
            
            start = CGPoint(x: start.x + jump, y: start.y)
        }
    }
    
    private func getRecordingTime() {
        var totalSecond : TimeInterval = 0.0
        recordingTimeLabel.text = totalSecond.minuteSecond
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            totalSecond += 1.0
            self.recordingTimeLabel.text = totalSecond.minuteSecond
        }
    }
    
    // MARK: - IBActions
    
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
    
    @IBAction func selectCutoffFrequency(_ sender: UISegmentedControl) {
        let selectedVoiceValue = sender.selectedSegmentIndex
        
        switch selectedVoiceValue {
        case 0:
            samplerate = 8000
        case 1:
            samplerate = 16000
        case 2:
            samplerate = 32000
        default:
            samplerate = 44100
        }
    }
}
// MARK: - Extensions

extension RecordDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(playButtonImage, for: .normal)
        recordButton.isHidden = false
        cutoffLabel.isHidden = false
        cutOffFreqSegmentedControl.isHidden = false
    }
}
