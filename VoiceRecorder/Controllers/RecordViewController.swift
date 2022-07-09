//
//  RecordViewController.swift
//  VoiceRecorder
//

import UIKit
import AVFoundation
import FirebaseStorage

class RecordViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var eq75HzSlider: UISlider!
    @IBOutlet weak var eq250HzSlider: UISlider!
    @IBOutlet weak var eq1040HzSlider: UISlider!
    @IBOutlet weak var eq2500HzSlider: UISlider!
    @IBOutlet weak var eq7500HzSlider: UISlider!
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playBackwardButton: UIButton!
    @IBOutlet weak var playForwardButton: UIButton!
    
    // MARK: - UI Components
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
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
    private var recordingSession = AVAudioSession.sharedInstance()
    private var isRecord = false
    private var isPlay = false
    private var recorderTimer: Timer?
    private var playerTimer: Timer?
    private var waveTimer: Timer?
    private var counter = 0.0
    private var buffer = LastNItemsBuffer<CGFloat>.init(count: 100)
    
    private let stepDuration = 0.01
    private let engine = AudioEngine()
    private let recorder = AudioRecorder()
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var decibels = [Int]()
    private var previousDecibels = [Int]()
    private var i = 0
    
    private lazy var eqSliderValues: [String] = [
        eq75HzSlider,
        eq250HzSlider,
        eq1040HzSlider,
        eq2500HzSlider,
        eq7500HzSlider
    ].map { String($0.value) }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        requestRecord()
        setupButton(isHidden: true)
        enableBuiltInMic()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        buffer.forceToValue(0.0)
        graphView.points = buffer
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelRecording()
    }
    
    // MARK: - @IBAction
    @IBAction func setCutOffFrequency(_ sender: UISlider) {
        sender.isContinuous = false
        let currentValue = Float(Int(sender.value))
        sender.value = currentValue
        
        switch sender {
        case eq75HzSlider:
            engine.gains[0] = currentValue
        case eq250HzSlider:
            engine.gains[1] = currentValue
        case eq1040HzSlider:
            engine.gains[2] = currentValue
        case eq2500HzSlider:
            engine.gains[3] = currentValue
        case eq7500HzSlider:
            engine.gains[4] = currentValue
        default:
            break
        }
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton) {
        if isRecord {
            sender.setImage(.circleFill)
            endRecord()
            blockEQSlider(isEnabled: true)
            graphView.reset()
            guard let data = recorder.data else { return }
            engine.url = fileName
            setupEngine()
            
            activityIndicator.startAnimating()
            
            uploadDecibelData(decibels) { result in
                switch result {
                case .success(let url):
                    let newMetaData = [
                        MetaData.duration.key: "\(ceil(self.engine.duration).toStringTimeFormat)",
                        MetaData.eq.key: self.eqSliderValues.joined(separator: " "),
                        MetaData.decibelDataURL.key: url.description
                    ]
                    self.previousDecibels = self.decibels
                    self.decibels = []
                    self.uploadFile(
                        data,
                        fileName: self.recordDate ?? "제목 없음",
                        newMetaData: newMetaData
                    ) { error in
                        if error != nil {
                            UIAlertController.showOKAlert(
                                self,
                                title: "ERROR",
                                message: "업로드에 실패 했습니다.",
                                handler: { _ in
                                    self.dismiss(animated: true)
                                }
                            )
                            return
                        }
                        self.activityIndicator.stopAnimating()
                        self.setupButton(isHidden: false)
                    }
                case .failure(_):
                    UIAlertController.showOKAlert(
                        self,
                        title: "ERROR",
                        message: "업로드에 실패 했습니다.",
                        handler: { _ in
                            self.dismiss(animated: true)
                        }
                    )
                }
            }
        } else {
            sender.setImage(.circle)
            setupAudioRecorder()
            recorder.record()
            blockEQSlider(isEnabled: false)
            setupButton(isHidden: true)
            graphView.drawBarGraph = true
            graphView.reset()
            
            recorderTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updateRecordTimer),
                userInfo: nil,
                repeats: true
            )
            waveTimer = Timer.scheduledTimer(
                timeInterval: stepDuration,
                target: self,
                selector: #selector(updateGraphTimer),
                userInfo: nil,
                repeats: true
            )
        }
        isRecord = !isRecord
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        engine.skip(forwards: false)
        graphView.reset()
        i -= 500
        if i < 0 {
            i = 0
        }
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        engine.skip(forwards: true)
        graphView.reset()
        i += 500
        if i >= previousDecibels.count {
            i = previousDecibels.count - 1
        }
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        if isPlay {
            sender.setImage(.play)
            playerTimer?.invalidate()
            engine.pause()
        } else {
            engine.play()
            
            playerTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updateRecordPlayerTimer),
                userInfo: nil,
                repeats: true
            )
            sender.setImage(.pauseFill)
        }
        isPlay = !isPlay
    }
}

// MARK: - @objc Methods
private extension RecordViewController {
    @objc func updateRecordTimer() {
        counter += 0.01
        recordTimeLabel.text = "\(counter.toStringTimeFormat)"
    }
    @objc func updateRecordPlayerTimer() {
        if engine.isFinish() {
            playButton.setImage(.play)
            isPlay = false
            playerTimer?.invalidate()
            engine.stop()
            engine.currentPosition = 0
            engine.seekFrame = 0
            i = 0
            recordTimeLabel.text = "\(engine.duration.toStringTimeFormat)"
            setupEngine()
        } else {
            recordTimeLabel.text = "\(engine.getCurrentTime().toStringTimeFormat)"
        }
        if i < previousDecibels.count {
            graphView.drawBarGraph = true
            let value = previousDecibels[i]
            if value > 160 {
                self.graphView.animateNewValue(
                    CGFloat(graphView.maxValue),
                    duration: self.stepDuration
                )
            } else {
                self.graphView.animateNewValue(
                    CGFloat(value),
                    duration: self.stepDuration
                )
            }
            i += 1
        }
    }
    @objc func updateGraphTimer() {
        recorder.updateMeters()
        let value = pow(Double(10), (0.05 * Double(recorder.averagePower))) * 110
        decibels.append(Int(value))
        if value > 160 {
            self.graphView.animateNewValue(CGFloat(graphView.maxValue), duration: self.stepDuration)
        } else {
            self.graphView.animateNewValue(CGFloat(value), duration: self.stepDuration)
        }
    }
    private func enableBuiltInMic() {
        let session = AVAudioSession.sharedInstance()
        guard let inputPorts = session.availableInputs,
              let builtInMic = inputPorts.first(where: { $0.portType == .builtInMic }) else {
            return
        }
        do {
            try session.setPreferredInput(builtInMic)
        } catch {
            UIAlertController.showOKAlert(
                self,
                title: "마이크 설정", message: "마이크 권한 설정해주세요.") { _ in
                    self.openSetting()
                }
        }
    }
}

// MARK: - Methods
private extension RecordViewController {
    func configureUI() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func setupAudioRecorder() {
        recordDate = Date.now.dateToString
        fileName = fileURL.appendingPathComponent("\(recordDate ?? "").m4a")
        guard let fileName = fileName else { return }
        recorder.path = fileName
        recorder.settings = recorderSetting
        recorder.setupAudioRecorder()
    }
    
    func requestRecord() {
        recordingSession.requestRecordPermission({ allowed in
            DispatchQueue.main.async {
                if !allowed {
                    UIAlertController.showOKAlert(
                        self,
                        title: "마이크 권한",
                        message: "마이크 권한을 설정해주세요.",
                        handler: { _ in self.openSetting() }
                    )
                }
            }
        })
    }
    
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setupButton(isHidden: Bool) {
        playButton.isHidden = isHidden
        playBackwardButton.isHidden = isHidden
        playForwardButton.isHidden = isHidden
    }
    
    func cancelRecording() {
        if isRecord {
            recorder.stop()
            recorder.deleteRecording()
            recorderTimer?.invalidate()
            waveTimer?.invalidate()
            delegate?.recordView(cancelRecord: true)
        }
        engine.stop()
        playerTimer?.invalidate()
    }
    
    func endRecord() {
        recorder.stop()
        recorderTimer?.invalidate()
        waveTimer?.invalidate()
        counter = 0.0
    }
    
    func uploadDecibelData(
        _ decibels: [Int],
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        StorageManager.shared.decibelUpload(decibels) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadFile(
        _ data: Data,
        fileName: String,
        newMetaData: [String: String],
        didFinish completion: @escaping (Error?) -> Void
    ) {
        StorageManager.shared.upload(
            data: data,
            fileName: fileName,
            newMetaData: newMetaData
        ) { result in
            switch result {
            case .success(_):
                self.delegate?.recordView(didFinishRecord: true)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func blockEQSlider(isEnabled: Bool) {
        eq75HzSlider.isEnabled = isEnabled
        eq250HzSlider.isEnabled = isEnabled
        eq1040HzSlider.isEnabled = isEnabled
        eq2500HzSlider.isEnabled = isEnabled
        eq7500HzSlider.isEnabled = isEnabled
        
        eq75HzSlider.thumbTintColor = isEnabled ? .white : .clear
        eq250HzSlider.thumbTintColor = isEnabled ? .white : .clear
        eq1040HzSlider.thumbTintColor = isEnabled ? .white : .clear
        eq2500HzSlider.thumbTintColor = isEnabled ? .white : .clear
        eq7500HzSlider.thumbTintColor = isEnabled ? .white : .clear
    }
    
    func setupEngine() {
        guard (try? engine.setupEngine()) != nil else { return }
    }
}
