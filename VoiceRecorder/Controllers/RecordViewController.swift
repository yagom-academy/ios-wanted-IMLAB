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
    private var buffer = LastNItemsBuffer<CGFloat>.init(count: 80)
    
    private let stepDuration = 0.01
    private let engine = AudioEngine()
    private let recorder = AudioRecorder()
    private let audioSession = AVAudioSession.sharedInstance()
    
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
        setupAudioRecorder()
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
            guard let data = recorder.data else { return }
            engine.url = fileName
            do {
            try engine.setupEngine()
            } catch {
                print(error)
            }
            let newMetaData = [
                MetaData.duration.key: "\(engine.audioLengthSeconds.toStringTimeFormat)",
                MetaData.eq.key: eqSliderValues.joined(separator: " ")
            ]
            
            activityIndicator.startAnimating()
            uploadFile(
                data,
                fileName: recordDate ?? "",
                newMetaData: newMetaData
            ) {
                self.activityIndicator.stopAnimating()
                self.setupButton(isHidden: false)
                self.blockEQSlider()
            }
            print(fileName)
        } else {
            sender.setImage(.circle)
            recorder.record()
            graphView.drawBarGraph = true
            
            recorderTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(update),
                userInfo: nil,
                repeats: true
            )
            waveTimer = Timer.scheduledTimer(
                timeInterval: stepDuration,
                target: self,
                selector: #selector(update3),
                userInfo: nil,
                repeats: true
            )
            isRecord = !isRecord
        }
    }
    
    @IBAction func didTapPlayBack5Button(_ sender: UIButton) {
        engine.seek(to: -3)
    }
    
    @IBAction func didTapPlayForward5Button(_ sender: UIButton) {
        engine.seek(to: 3)
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
                selector: #selector(update2),
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
    @objc func update() {
        counter += 0.01
        recordTimeLabel.text = "\(counter.toStringTimeFormat)"
    }
    @objc func update2() {
        print(engine.getCurrentTime())
        if engine.isFinish() {
            playButton.setImage(.play)
            isPlay = false
            playerTimer?.invalidate()
            engine.stop()
            try! engine.setupEngine()
        } else {
            recordTimeLabel.text = "\(engine.getCurrentTime().toStringTimeFormat)"
        }
    }
    @objc func update3() {
        recorder.updateMeters()
        let value = pow(Double(10), (0.05 * Double(recorder.averagePower))) * 100
        if value > 160 {
            self.graphView.animateNewValue(CGFloat(graphView.maxValue), duration: self.stepDuration)
        } else {
            self.graphView.animateNewValue(CGFloat(value), duration: self.stepDuration)
        }
        print(value)
        
    }
    private func enableBuiltInMic() {
        let session = AVAudioSession.sharedInstance()
        guard let inputPorts = session.availableInputs,
              let builtInMic = inputPorts.first(where: { $0.portType == .builtInMic }) else {
            print("The device must have a built-in microphone.")
            return
        }
        do {
            try session.setPreferredInput(builtInMic)
        } catch {
            print("Unable to set the built-in mic as the preferred input.")
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
    
    func setupButton(isHidden: Bool) {
        playButton.isHidden = isHidden
        playBackwardButton.isHidden = isHidden
        playForwardButton.isHidden = isHidden
        if isHidden == false {
            recordButton.isHidden = true
        }
    }
    
    func cancelRecording() {
        if isRecord {
            recorder.stop()
            recorder.deleteRecording()
            recorderTimer?.invalidate()
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
    
    func uploadFile(
        _ data: Data,
        fileName: String,
        newMetaData: [String: String],
        didFinish completion: @escaping () -> Void
    ) {
        StorageManager.shared.upload(
            data: data,
            fileName: fileName,
            newMetaData: newMetaData
        ) { result in
            switch result {
            case .success(_):
                print("저장 성공🎉")
                self.delegate?.recordView(didFinishRecord: true)
                completion()
            case .failure(let error):
                print("ERROR \(error.localizedDescription)🌡🌡")
            }
        }
    }
    
    func blockEQSlider() {
        eq75HzSlider.isEnabled = false
        eq250HzSlider.isEnabled = false
        eq1040HzSlider.isEnabled = false
        eq2500HzSlider.isEnabled = false
        eq7500HzSlider.isEnabled = false
        
        eq75HzSlider.thumbTintColor = .clear
        eq250HzSlider.thumbTintColor = .clear
        eq1040HzSlider.thumbTintColor = .clear
        eq2500HzSlider.thumbTintColor = .clear
        eq7500HzSlider.thumbTintColor = .clear
    }
    
}
